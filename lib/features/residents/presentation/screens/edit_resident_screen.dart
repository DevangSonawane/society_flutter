import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/animations/fade_slide_widget.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../data/models/resident_model.dart';
import '../../data/models/vehicle_model.dart';
import '../../providers/residents_provider.dart';
import 'package:uuid/uuid.dart';

class EditResidentScreen extends ConsumerStatefulWidget {
  final ResidentModel resident;

  const EditResidentScreen({
    super.key,
    required this.resident,
  });

  @override
  ConsumerState<EditResidentScreen> createState() => _EditResidentScreenState();
}

class _EditResidentScreenState extends ConsumerState<EditResidentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ownerNameController;
  late TextEditingController _flatNumberController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  
  late ResidentType _selectedType;
  
  late List<ResidentMember> _members;
  late List<VehicleModel> _vehicles;
  
  final _memberNameController = TextEditingController();
  final _memberPhoneController = TextEditingController();
  DateTime? _memberDateJoined;
  
  final _vehicleNumberController = TextEditingController();
  String _selectedVehicleType = 'Car';
  
  final _uuid = const Uuid();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ownerNameController = TextEditingController(text: widget.resident.ownerName);
    _flatNumberController = TextEditingController(text: widget.resident.flatNumber);
    _phoneController = TextEditingController(text: widget.resident.phoneNumber);
    _emailController = TextEditingController(text: widget.resident.email ?? '');
    _selectedType = widget.resident.residencyType;
    _members = List.from(widget.resident.residentsLiving);
    _vehicles = List.from(widget.resident.vehicleDetail);
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _flatNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _memberNameController.dispose();
    _memberPhoneController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }

  void _addMember() {
    if (_memberNameController.text.isNotEmpty && _memberPhoneController.text.isNotEmpty) {
      HapticHelper.light();
      setState(() {
        _members.add(ResidentMember(
          id: _uuid.v4(),
          name: _memberNameController.text,
          phoneNumber: _memberPhoneController.text,
          dateJoined: _memberDateJoined != null 
              ? _memberDateJoined!.toIso8601String().split('T')[0]
              : null,
        ));
        _memberNameController.clear();
        _memberPhoneController.clear();
        _memberDateJoined = null;
      });
    }
  }

  void _removeMember(int index) {
    HapticHelper.light();
    setState(() {
      _members.removeAt(index);
    });
  }

  void _addVehicle() {
    if (_vehicleNumberController.text.isNotEmpty) {
      HapticHelper.light();
      setState(() {
        _vehicles.add(VehicleModel(
          vehicleNumber: _vehicleNumberController.text,
          vehicleType: _selectedVehicleType,
        ));
        _vehicleNumberController.clear();
      });
    }
  }

  void _removeVehicle(int index) {
    HapticHelper.light();
    setState(() {
      _vehicles.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final resident = ResidentModel(
      id: widget.resident.id,
      ownerName: _ownerNameController.text,
      flatNumber: _flatNumberController.text,
      residencyType: _selectedType,
      phoneNumber: _phoneController.text,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      createdAt: widget.resident.createdAt,
      updatedAt: DateTime.now(),
      residentsLiving: _members,
      vehicleDetail: _vehicles,
      rentAgreementUrl: widget.resident.rentAgreementUrl,
      currentRenterName: widget.resident.currentRenterName,
      currentRenterPhone: widget.resident.currentRenterPhone,
      currentRenterEmail: widget.resident.currentRenterEmail,
      oldRenterName: widget.resident.oldRenterName,
      oldRenterPhone: widget.resident.oldRenterPhone,
      oldRenterEmail: widget.resident.oldRenterEmail,
      rentStartDate: widget.resident.rentStartDate,
      rentEndDate: widget.resident.rentEndDate,
      monthlyRent: widget.resident.monthlyRent,
      documents: widget.resident.documents,
      brokerName: widget.resident.brokerName,
      brokerPhone: widget.resident.brokerPhone,
      brokerEmail: widget.resident.brokerEmail,
      brokerCompany: widget.resident.brokerCompany,
      brokerCommission: widget.resident.brokerCommission,
      ownerHistory: widget.resident.ownerHistory,
    );

    try {
      await ref.read(residentsNotifierProvider.notifier).updateResident(resident);
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Resident updated successfully'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating resident: ${e.toString()}'),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Resident',
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeSlideWidget(
                delay: const Duration(milliseconds: 100),
                child: CustomButton(
                  text: 'Back to Residents',
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.pop(context),
                  type: ButtonType.secondary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Basic Information Section
              FadeSlideWidget(
                delay: const Duration(milliseconds: 200),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.borderLight),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text('Basic Information', style: AppTextStyles.h3),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          label: "Owner's Name *",
                          controller: _ownerNameController,
                          validator: (value) => Validators.required(value, fieldName: "Owner's Name"),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Flat Number *',
                          controller: _flatNumberController,
                          validator: (value) => Validators.required(value, fieldName: 'Flat Number'),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<ResidentType>(
                          value: _selectedType,
                          decoration: InputDecoration(
                            labelText: 'Residency Type *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: ResidentType.values.map((type) {
                            String label;
                            switch (type) {
                              case ResidentType.ownerLiving:
                                label = 'Owner-Living';
                                break;
                              case ResidentType.rented:
                                label = 'Rented';
                                break;
                            }
                            return DropdownMenuItem(value: type, child: Text(label));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                            });
                            HapticHelper.selection();
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Phone Number *',
                          controller: _phoneController,
                          validator: Validators.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Email Address',
                          controller: _emailController,
                          validator: (value) => value?.isEmpty ?? true ? null : Validators.email(value),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Add Residents Section
              FadeSlideWidget(
                delay: const Duration(milliseconds: 300),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.borderLight),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text('Add Residents', style: AppTextStyles.h3),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Name',
                                controller: _memberNameController,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                label: 'Phone Number',
                                controller: _memberPhoneController,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                label: 'Date Joined',
                                controller: TextEditingController(
                                  text: _memberDateJoined != null
                                      ? '${_memberDateJoined!.day}/${_memberDateJoined!.month}/${_memberDateJoined!.year}'
                                      : '',
                                ),
                                readOnly: true,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () async {
                                    HapticHelper.selection();
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      setState(() {
                                        _memberDateJoined = date;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Add Resident',
                          icon: Icons.add,
                          onPressed: _addMember,
                          type: ButtonType.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Members List
              ..._members.asMap().entries.map((entry) {
                final index = entry.key;
                final member = entry.value;
                return FadeSlideWidget(
                  delay: Duration(milliseconds: 300 + (index * 50)),
                  key: ValueKey(member.id),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(member.name),
                      subtitle: Text(member.phoneNumber),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.errorRed),
                        onPressed: () => _removeMember(index),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              
              // Vehicle Information Section
              FadeSlideWidget(
                delay: const Duration(milliseconds: 400),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.borderLight),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.directions_car,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text('Vehicle Information', style: AppTextStyles.h3),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Vehicle Number',
                                controller: _vehicleNumberController,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedVehicleType,
                                decoration: InputDecoration(
                                  labelText: 'Vehicle Type',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                items: ['Car', 'Bike', 'Scooter', 'Other']
                                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedVehicleType = value!;
                                  });
                                  HapticHelper.selection();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Add Vehicle',
                          icon: Icons.add,
                          onPressed: _addVehicle,
                          type: ButtonType.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Vehicles List
              ..._vehicles.asMap().entries.map((entry) {
                final index = entry.key;
                final vehicle = entry.value;
                return FadeSlideWidget(
                  delay: Duration(milliseconds: 400 + (index * 50)),
                  key: ValueKey('${vehicle.vehicleNumber}_${vehicle.vehicleType}'),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(vehicle.vehicleNumber),
                      subtitle: Text(vehicle.vehicleType),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.errorRed),
                        onPressed: () => _removeVehicle(index),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 32),
              
              // Form Actions
              FadeSlideWidget(
                delay: const Duration(milliseconds: 500),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                        type: ButtonType.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Update Resident',
                        icon: Icons.save,
                        onPressed: _submitForm,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

