import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/animations/fade_slide_widget.dart';
import '../../../../shared/widgets/custom_snackbar.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/resident_model.dart';
import '../../data/models/vehicle_model.dart';
import '../../providers/residents_provider.dart';
import 'package:uuid/uuid.dart';

class CreateResidentScreen extends ConsumerStatefulWidget {
  const CreateResidentScreen({super.key});

  @override
  ConsumerState<CreateResidentScreen> createState() => _CreateResidentScreenState();
}

class _CreateResidentScreenState extends ConsumerState<CreateResidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameController = TextEditingController();
  final _flatNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  ResidentType _selectedType = ResidentType.ownerLiving;
  
  final List<ResidentMember> _members = [];
  final List<VehicleModel> _vehicles = [];
  final List<Map<String, dynamic>> _documents = []; // {name, url, size}
  
  final _memberNameController = TextEditingController();
  final _memberPhoneController = TextEditingController();
  DateTime? _memberDateJoined;
  
  final _vehicleNumberController = TextEditingController();
  String _selectedVehicleType = 'Car';
  
  final _uuid = const Uuid();
  bool _isLoading = false;
  bool _isUploadingDocument = false;

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
          dateJoined: _memberDateJoined ?? DateTime.now(),
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
          id: _uuid.v4(),
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

  Future<void> _addDocument() async {
    HapticHelper.light();
    
    final file = await StorageService.pickFile(
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      dialogTitle: 'Select Document',
    );

    if (file == null) return;

    setState(() {
      _isUploadingDocument = true;
    });

    try {
      final fileSize = await StorageService.getFileSize(file);
      final fileName = file.path.split('/').last;
      
      // Upload to Supabase Storage
      final url = await StorageService.uploadFile(
        file: file,
        folder: 'residents/documents',
        fileName: '${_uuid.v4()}_$fileName',
      );

      if (url != null) {
        setState(() {
          _documents.add({
            'name': fileName,
            'url': url,
            'size': fileSize,
            'type': _getFileType(fileName),
          });
        });
        
        if (mounted) {
          CustomSnackbar.show(
            context,
            message: 'Document uploaded successfully',
            type: SnackbarType.success,
          );
        }
      } else {
        if (mounted) {
          CustomSnackbar.show(
            context,
            message: 'Failed to upload document. Please try again.',
            type: SnackbarType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Error uploading document: ${e.toString()}',
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingDocument = false;
        });
      }
    }
  }

  void _removeDocument(int index) {
    HapticHelper.light();
    setState(() {
      _documents.removeAt(index);
    });
  }

  String _getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      return 'image';
    } else if (['pdf'].contains(extension)) {
      return 'pdf';
    } else if (['doc', 'docx'].contains(extension)) {
      return 'document';
    }
    return 'file';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final resident = ResidentModel(
      id: _uuid.v4(),
      ownerName: _ownerNameController.text,
      flatNumber: _flatNumberController.text,
      residencyType: _selectedType,
      phoneNumber: _phoneController.text,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      createdAt: DateTime.now(),
      residentsLiving: _members,
      vehicleDetail: _vehicles,
      documents: _documents.isNotEmpty ? _documents : null,
    );

    await ref.read(residentsNotifierProvider.notifier).createResident(resident);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context);
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
          'Create Resident',
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
              // Back Button
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
              
              // Owner Information Section
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
                    const SizedBox(height: 16),
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
                      decoration: const InputDecoration(
                        labelText: 'Residency Type *',
                        border: OutlineInputBorder(),
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Name',
                            controller: _memberNameController,
                            hint: 'Resident name',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            label: 'Phone Number',
                            controller: _memberPhoneController,
                            hint: 'Phone number',
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
              
              // Members List with staggered animations
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
                    const SizedBox(height: 16),
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
                            decoration: const InputDecoration(
                              labelText: 'Vehicle Type',
                              border: OutlineInputBorder(),
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
              
              // Vehicles List with staggered animations
              ..._vehicles.asMap().entries.map((entry) {
                final index = entry.key;
                final vehicle = entry.value;
                return FadeSlideWidget(
                  delay: Duration(milliseconds: 400 + (index * 50)),
                  key: ValueKey(vehicle.id),
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
              const SizedBox(height: 24),
              
              // Additional Documents Section
              FadeSlideWidget(
                delay: const Duration(milliseconds: 500),
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
                              Icons.description,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text('Additional Documents', style: AppTextStyles.h3),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Add Document',
                          icon: Icons.attach_file,
                          onPressed: _isUploadingDocument ? null : _addDocument,
                          isLoading: _isUploadingDocument,
                          type: ButtonType.secondary,
                        ),
                        if (_documents.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ..._documents.asMap().entries.map((entry) {
                            final index = entry.key;
                            final doc = entry.value;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(
                                  _getFileType(doc['name']) == 'image'
                                      ? Icons.image
                                      : _getFileType(doc['name']) == 'pdf'
                                          ? Icons.picture_as_pdf
                                          : Icons.description,
                                  color: AppColors.primaryPurple,
                                ),
                                title: Text(
                                  doc['name'],
                                  style: AppTextStyles.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  StorageService.formatFileSize(doc['size']),
                                  style: AppTextStyles.bodySmall,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: AppColors.errorRed),
                                  onPressed: () => _removeDocument(index),
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
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
                        text: 'Create Resident',
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

