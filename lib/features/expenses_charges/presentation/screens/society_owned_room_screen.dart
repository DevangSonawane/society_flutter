import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/statistics_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/responsive_statistics_grid.dart';
import '../../../../shared/widgets/data_table_widget.dart';
import '../../../../shared/widgets/table_action_buttons.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/animations/shimmer_loading.dart';
import '../../../../shared/widgets/animated_dialog.dart';
import '../../../../shared/widgets/custom_snackbar.dart';
import '../../data/models/society_room_model.dart';
import '../../providers/society_rooms_provider.dart';
import 'add_society_room_screen.dart';

class SocietyOwnedRoomScreen extends ConsumerStatefulWidget {
  const SocietyOwnedRoomScreen({super.key});

  @override
  ConsumerState<SocietyOwnedRoomScreen> createState() => _SocietyOwnedRoomScreenState();
}

class _SocietyOwnedRoomScreenState extends ConsumerState<SocietyOwnedRoomScreen> {
  String _searchQuery = '';

  Color _getStatusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return AppColors.successGreen;
      case RoomStatus.occupied:
        return AppColors.primaryPurple;
      case RoomStatus.maintenance:
        return AppColors.warningYellow;
    }
  }

  String _getStatusLabel(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return 'Available';
      case RoomStatus.occupied:
        return 'Occupied';
      case RoomStatus.maintenance:
        return 'Maintenance';
    }
  }

  String _getTypeLabel(RoomType type) {
    switch (type) {
      case RoomType.commercialOffice:
        return 'Commercial Office';
      case RoomType.shop:
        return 'Shop';
    }
  }

  Future<void> _deleteRoom(String id, String roomNumber) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AnimatedAlertDialog(
        title: 'Delete Room',
        content: Text('Are you sure you want to delete room $roomNumber? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(societyRoomsNotifierProvider.notifier).deleteRoom(id);
        if (mounted) {
          CustomSnackbar.show(
            context,
            message: 'Room deleted successfully',
            type: SnackbarType.success,
          );
        }
      } catch (e) {
        if (mounted) {
          CustomSnackbar.show(
            context,
            message: 'Error deleting room: ${e.toString()}',
            type: SnackbarType.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(societyRoomsNotifierProvider);
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.getScreenPadding(context);

    return roomsAsync.when(
      data: (rooms) {
        final occupied = rooms.where((r) => r.status == RoomStatus.occupied).length;
        final available = rooms.where((r) => r.status == RoomStatus.available).length;
        
        final filteredRooms = _searchQuery.isEmpty
            ? rooms
            : rooms.where((r) {
                final query = _searchQuery.toLowerCase();
                return r.roomNumber.toLowerCase().contains(query) ||
                    (r.shopOwnerName != null && r.shopOwnerName!.toLowerCase().contains(query)) ||
                    (r.shopOfficeName != null && r.shopOfficeName!.toLowerCase().contains(query));
              }).toList();

        return Container(
          color: AppColors.backgroundLight,
          child: SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Society Owned Room', style: AppTextStyles.h1),
                          const SizedBox(height: 4),
                          Text(
                            'Manage charges for society-owned rooms/spaces',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: 'Add Room',
                              icon: Icons.add,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddSocietyRoomScreen(),
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
                              Text('Society Owned Room', style: AppTextStyles.h1),
                              const SizedBox(height: 4),
                              Text(
                                'Manage charges for society-owned rooms/spaces',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          CustomButton(
                            text: 'Add Room',
                            icon: Icons.add,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddSocietyRoomScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                const SizedBox(height: 24),
                
                ResponsiveStatisticsGrid(
                  children: [
                    StatisticsCard(
                      title: 'Total Rooms',
                      value: '${rooms.length}',
                      subtitle: 'Registered rooms',
                      borderColor: AppColors.primaryPurple,
                      valueColor: AppColors.primaryPurple,
                      icon: Icons.room,
                      showTrend: true,
                    ),
                    StatisticsCard(
                      title: 'Occupied',
                      value: '$occupied',
                      subtitle: 'Currently occupied',
                      borderColor: AppColors.successGreen,
                      valueColor: AppColors.successGreen,
                      icon: Icons.check_circle,
                      showTrend: true,
                    ),
                    StatisticsCard(
                      title: 'Available',
                      value: '$available',
                      subtitle: 'Available rooms',
                      borderColor: AppColors.infoBlue,
                      valueColor: AppColors.infoBlue,
                      icon: Icons.event_available,
                      showTrend: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by room number, owner, or office name...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: 24),
                
                filteredRooms.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.room,
                        title: 'No rooms found',
                        message: _searchQuery.isEmpty
                            ? 'Add your first room to get started'
                            : 'Try adjusting your search query',
                      )
                    : isMobile
                        ? Column(
                            children: filteredRooms.map((room) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
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
                                                  room.roomNumber,
                                                  style: AppTextStyles.h4,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _getTypeLabel(room.roomType),
                                                  style: AppTextStyles.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(room.status).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _getStatusLabel(room.status),
                                              style: TextStyle(
                                                color: _getStatusColor(room.status),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (room.shopOwnerName != null || room.shopOfficeName != null) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          room.shopOfficeName ?? room.shopOwnerName ?? '',
                                          style: AppTextStyles.bodyMedium,
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20, color: AppColors.errorRed),
                                            onPressed: () => _deleteRoom(room.id, room.roomNumber),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : DataTableWidget(
                            columns: const [
                              'Room Number',
                              'Type',
                              'Status',
                              'Owner/Office',
                              'Actions',
                            ],
                            rows: filteredRooms.map((room) {
                              return [
                                Text(room.roomNumber),
                                Text(_getTypeLabel(room.roomType)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(room.status).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getStatusLabel(room.status),
                                    style: TextStyle(
                                      color: _getStatusColor(room.status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(room.shopOfficeName ?? room.shopOwnerName ?? 'N/A'),
                                TableActionButtons(
                                  onDelete: () => _deleteRoom(room.id, room.roomNumber),
                                ),
                              ];
                            }).toList(),
                          ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        color: AppColors.backgroundLight,
        child: SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerLoading(width: 200, height: 32),
              const SizedBox(height: 24),
              ResponsiveStatisticsGrid(
                children: List.generate(3, (index) => const ShimmerLoading(width: double.infinity, height: 120)),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => ErrorStateWidget(
        message: error.toString(),
        onRetry: () => ref.refresh(societyRoomsNotifierProvider),
      ),
    );
  }
}

