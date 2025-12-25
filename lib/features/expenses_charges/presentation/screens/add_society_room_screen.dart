import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/animations/fade_slide_widget.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../../shared/widgets/custom_snackbar.dart';
import '../../data/models/society_room_model.dart';
import '../../providers/society_rooms_provider.dart';
import 'package:uuid/uuid.dart';

class AddSocietyRoomScreen extends ConsumerStatefulWidget {
  const AddSocietyRoomScreen({super.key});

  @override
  ConsumerState<AddSocietyRoomScreen> createState() => _AddSocietyRoomScreenState();
}

class _AddSocietyRoomScreenState extends ConsumerState<AddSocietyRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomNumberController = TextEditingController();
  final _shopOwnerNameController = TextEditingController();
  final _shopOwnerPhoneController = TextEditingController();
  final _shopOwnerEmailController = TextEditingController();
  final _shopOfficeNameController = TextEditingController();
  final _officeTelephoneController = TextEditingController();
  final _workersEmployeesController = TextEditingController();
  final _managerNameController = TextEditingController();
  final _managerPhoneController = TextEditingController();
  final _financeMonthController = TextEditingController();
  final _financeMoneyController = TextEditingController();
  final _notesController = TextEditingController();
  
  RoomType _selectedRoomType = RoomType.commercialOffice;
  RoomStatus _selectedStatus = RoomStatus.available;
  bool _isLoading = false;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _roomNumberController.dispose();
    _shopOwnerNameController.dispose();
    _shopOwnerPhoneController.dispose();
    _shopOwnerEmailController.dispose();
    _shopOfficeNameController.dispose();
    _officeTelephoneController.dispose();
    _workersEmployeesController.dispose();
    _managerNameController.dispose();
    _managerPhoneController.dispose();
    _financeMonthController.dispose();
    _financeMoneyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final room = SocietyRoomModel(
      id: _uuid.v4(),
      roomNumber: _roomNumberController.text.trim(),
      roomType: _selectedRoomType,
      status: _selectedStatus,
      shopOwnerName: _shopOwnerNameController.text.trim().isNotEmpty
          ? _shopOwnerNameController.text.trim()
          : null,
      shopOwnerPhone: _shopOwnerPhoneController.text.trim().isNotEmpty
          ? _shopOwnerPhoneController.text.trim()
          : null,
      shopOwnerEmail: _shopOwnerEmailController.text.trim().isNotEmpty
          ? _shopOwnerEmailController.text.trim()
          : null,
      shopOfficeName: _shopOfficeNameController.text.trim().isNotEmpty
          ? _shopOfficeNameController.text.trim()
          : null,
      officeTelephone: _officeTelephoneController.text.trim().isNotEmpty
          ? _officeTelephoneController.text.trim()
          : null,
      workersEmployees: _workersEmployeesController.text.trim().isNotEmpty
          ? int.tryParse(_workersEmployeesController.text.trim())
          : null,
      managerName: _managerNameController.text.trim().isNotEmpty
          ? _managerNameController.text.trim()
          : null,
      managerPhone: _managerPhoneController.text.trim().isNotEmpty
          ? _managerPhoneController.text.trim()
          : null,
      financeMonth: _financeMonthController.text.trim().isNotEmpty
          ? int.tryParse(_financeMonthController.text.trim())
          : null,
      financeMoney: _financeMoneyController.text.trim().isNotEmpty
          ? double.tryParse(_financeMoneyController.text.trim())
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(societyRoomsNotifierProvider.notifier).createRoom(room);
      
      if (!mounted) return;

      CustomSnackbar.show(
        context,
        message: 'Room added successfully',
        type: SnackbarType.success,
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      CustomSnackbar.show(
        context,
        message: 'Error adding room: ${e.toString()}',
        type: SnackbarType.error,
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    final padding = isMobile ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Add Room', style: AppTextStyles.h2),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideWidget(
                delay: const Duration(milliseconds: 100),
                child: CustomButton(
                  text: 'Back to Rooms',
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.pop(context),
                  type: ButtonType.secondary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Basic Information
              FadeSlideWidget(
                delay: const Duration(milliseconds: 200),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
                              Icons.room,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text('Basic Information', style: AppTextStyles.h3),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        CustomTextField(
                          label: 'Room Number *',
                          controller: _roomNumberController,
                          hint: 'Enter room number',
                          validator: (value) => Validators.required(value, fieldName: 'Room Number'),
                        ),
                        const SizedBox(height: 16),
                        
                        DropdownButtonFormField<RoomType>(
                          value: _selectedRoomType,
                          decoration: const InputDecoration(
                            labelText: 'Room Type *',
                            border: OutlineInputBorder(),
                          ),
                          items: RoomType.values.map((type) {
                            String label;
                            switch (type) {
                              case RoomType.commercialOffice:
                                label = 'Commercial Office';
                                break;
                              case RoomType.shop:
                                label = 'Shop';
                                break;
                            }
                            return DropdownMenuItem(
                              value: type,
                              child: Text(label),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRoomType = value!;
                            });
                            HapticHelper.selection();
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        DropdownButtonFormField<RoomStatus>(
                          value: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status *',
                            border: OutlineInputBorder(),
                          ),
                          items: RoomStatus.values.map((status) {
                            String label;
                            switch (status) {
                              case RoomStatus.available:
                                label = 'Available';
                                break;
                              case RoomStatus.occupied:
                                label = 'Occupied';
                                break;
                              case RoomStatus.maintenance:
                                label = 'Maintenance';
                                break;
                            }
                            return DropdownMenuItem(
                              value: status,
                              child: Text(label),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value!;
                            });
                            HapticHelper.selection();
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Notes',
                          controller: _notesController,
                          hint: 'Additional notes (optional)',
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Owner/Shop Information
              FadeSlideWidget(
                delay: const Duration(milliseconds: 300),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
                              Icons.business,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text('Owner/Shop Information', style: AppTextStyles.h3),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        CustomTextField(
                          label: 'Shop/Owner Name',
                          controller: _shopOwnerNameController,
                          hint: 'Enter name',
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Phone Number',
                          controller: _shopOwnerPhoneController,
                          hint: 'Enter phone number',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Email',
                          controller: _shopOwnerEmailController,
                          hint: 'Enter email',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => value?.isEmpty ?? true ? null : Validators.email(value),
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Shop/Office Name',
                          controller: _shopOfficeNameController,
                          hint: 'Enter shop/office name',
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Office Telephone',
                          controller: _officeTelephoneController,
                          hint: 'Enter office telephone',
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Additional Information
              FadeSlideWidget(
                delay: const Duration(milliseconds: 400),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
                              Icons.info,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text('Additional Information', style: AppTextStyles.h3),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        CustomTextField(
                          label: 'Workers/Employees',
                          controller: _workersEmployeesController,
                          hint: 'Enter number',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Manager Name',
                          controller: _managerNameController,
                          hint: 'Enter manager name',
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Manager Phone',
                          controller: _managerPhoneController,
                          hint: 'Enter manager phone',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Finance Month',
                          controller: _financeMonthController,
                          hint: 'Enter month (1-12)',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Finance Money',
                          controller: _financeMoneyController,
                          hint: 'Enter amount',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
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
                        text: 'Add Room',
                        icon: Icons.check,
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

