import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/statistics_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/responsive_statistics_grid.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/animated_dialog.dart';
import '../../../../core/routes/page_transitions.dart';
import '../../data/models/resident_model.dart';
import '../../providers/residents_provider.dart';
import 'create_resident_screen.dart';
import 'edit_resident_screen.dart';
import 'view_resident_screen.dart';

class ResidentsListScreen extends ConsumerStatefulWidget {
  const ResidentsListScreen({super.key});

  @override
  ConsumerState<ResidentsListScreen> createState() => _ResidentsListScreenState();
}

class _ResidentsListScreenState extends ConsumerState<ResidentsListScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'All Status';
  String _selectedType = 'All Type';

  @override
  Widget build(BuildContext context) {
    final residentsAsync = ref.watch(residentsNotifierProvider);
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.getScreenPadding(context);

    return Container(
      color: AppColors.backgroundLight,
      child: residentsAsync.when(
        data: (residents) {
          final activeResidents = residents.where((r) => r.status == 'active').length;
          final ownerOccupied = residents.where((r) => r.residencyType == ResidentType.ownerLiving).length;
          
          // Filter residents with enhanced search
          var filteredResidents = residents;
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            filteredResidents = residents.where((r) {
              return r.ownerName.toLowerCase().contains(query) ||
                  r.flatNumber.toLowerCase().contains(query) ||
                  (r.email?.toLowerCase().contains(query) ?? false) ||
                  r.phoneNumber.toLowerCase().contains(query) ||
                  r.members.any((m) => 
                    m.name.toLowerCase().contains(query) ||
                    m.phoneNumber.toLowerCase().contains(query)
                  );
            }).toList();
          }
          if (_selectedStatus != 'All Status') {
            filteredResidents = filteredResidents.where((r) => r.status == _selectedStatus.toLowerCase()).toList();
          }
          if (_selectedType != 'All Type') {
            filteredResidents = filteredResidents.where((r) {
              if (_selectedType == 'Owner-Living') {
                return r.residencyType == ResidentType.ownerLiving;
              } else if (_selectedType == 'Rented') {
                return r.residencyType == ResidentType.rented;
              }
              return true;
            }).toList();
          }

          return SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Residents', style: AppTextStyles.h1),
                          const SizedBox(height: 4),
                          Text(
                            'Manage society residents and their information',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: 'Add Resident',
                              icon: Icons.add,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  FadeSlidePageRoute(
                                    page: const CreateResidentScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Residents', style: AppTextStyles.h1),
                              const SizedBox(height: 4),
                              Text(
                                'Manage society residents and their information',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          CustomButton(
                            text: 'Add Resident',
                            icon: Icons.add,
                            onPressed: () {
                              Navigator.pushNamed(context, AppConstants.createResidentRoute);
                            },
                          ),
                        ],
                      ),
                const SizedBox(height: 24),
                
                // Statistics Cards - Responsive
                ResponsiveStatisticsGrid(
                  children: [
                    StatisticsCard(
                      title: 'Total Residents',
                      value: '${residents.length}',
                      subtitle: 'Registered residents',
                      borderColor: AppColors.primaryPurple,
                      valueColor: AppColors.primaryPurple,
                      icon: Icons.people,
                      showTrend: true,
                    ),
                    StatisticsCard(
                      title: 'Active',
                      value: '$activeResidents',
                      subtitle: 'Currently active',
                      borderColor: AppColors.successGreen,
                      valueColor: AppColors.successGreen,
                      icon: Icons.check_circle,
                      showTrend: true,
                    ),
                    StatisticsCard(
                      title: 'Owner Occupied',
                      value: '$ownerOccupied',
                      subtitle: 'Owner occupied',
                      borderColor: AppColors.infoBlue,
                      valueColor: AppColors.infoBlue,
                      icon: Icons.home,
                      showTrend: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Search and Filters - Responsive
                isMobile
                    ? Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Search residents or flat number...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: AppColors.white,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedStatus,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: AppColors.white,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  items: ['All Status', 'Active', 'Inactive']
                                      .map((status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(status),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedStatus = value!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedType,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: AppColors.white,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  items: ['All Type', 'Owner-Living', 'Rented']
                                      .map((type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedType = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search residents or flat number...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: AppColors.white,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: _selectedStatus,
                            items: ['All Status', 'Active', 'Inactive']
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value!;
                              });
                            },
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: _selectedType,
                            items: ['All Type', 'Owner-Living', 'Rented']
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                            },
                          ),
                        ],
                      ),
                const SizedBox(height: 24),
                
                // Residents Table/Cards - Responsive
                if (filteredResidents.isEmpty)
                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No residents found',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (isMobile)
                  // Mobile Card View
                  Column(
                    children: filteredResidents.map((resident) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          resident.ownerName,
                                          style: AppTextStyles.h4,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          resident.flatNumber,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: resident.status == 'active'
                                          ? AppColors.successGreenLight
                                          : AppColors.gray200,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      resident.status,
                                      style: TextStyle(
                                        color: resident.status == 'active'
                                            ? AppColors.successGreen
                                            : AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.phone, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Text(
                                    resident.phoneNumber,
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.home, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Text(
                                    resident.typeString,
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${resident.members.length} residents',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility, size: 20),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewResidentScreen(resident: resident),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditResidentScreen(resident: resident),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20, color: AppColors.errorRed),
                                    onPressed: () {
                                      _deleteResident(resident.id);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )
                else
                  // Desktop Table View
                  Card(
                    elevation: 0,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Flat Number')),
                          DataColumn(label: Text('Type')),
                          DataColumn(label: Text('Phone')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Created Date')),
                          DataColumn(label: Text('Residents')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: filteredResidents.map((resident) {
                          return DataRow(
                            cells: [
                              DataCell(Text(resident.ownerName)),
                              DataCell(Text(resident.flatNumber)),
                              DataCell(Text(resident.typeString)),
                              DataCell(Text(resident.phoneNumber)),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: resident.status == 'active'
                                        ? AppColors.successGreenLight
                                        : AppColors.gray200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    resident.status,
                                    style: TextStyle(
                                      color: resident.status == 'active'
                                          ? AppColors.successGreen
                                          : AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(AppFormatters.dateShort(resident.createdAt))),
                              DataCell(Text('${resident.members.length} residents')),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility, size: 20),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ViewResidentScreen(resident: resident),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditResidentScreen(resident: resident),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20, color: AppColors.errorRed),
                                      onPressed: () {
                                        _deleteResident(resident.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.errorRed),
                const SizedBox(height: 16),
                Text(
                  'Error loading residents',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteResident(String id) {
    AnimatedAlertDialog.show(
      context: context,
      title: 'Delete Resident',
      content: const Text('Are you sure you want to delete this resident?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            ref.read(residentsNotifierProvider.notifier).deleteResident(id);
            Navigator.pop(context);
          },
          child: const Text('Delete', style: TextStyle(color: AppColors.errorRed)),
        ),
      ],
    );
  }
}
