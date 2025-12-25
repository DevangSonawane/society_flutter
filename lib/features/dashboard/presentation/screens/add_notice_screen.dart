import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/animations/fade_slide_widget.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../data/models/notice_model.dart';
import '../../providers/notices_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddNoticeScreen extends ConsumerStatefulWidget {
  const AddNoticeScreen({super.key});

  @override
  ConsumerState<AddNoticeScreen> createState() => _AddNoticeScreenState();
}

class _AddNoticeScreenState extends ConsumerState<AddNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  NoticePriority _selectedPriority = NoticePriority.medium;
  NoticeCategory _selectedCategory = NoticeCategory.general;
  DateTime _noticeDate = DateTime.now();
  bool _isLoading = false;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _noticeDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _noticeDate) {
      setState(() {
        _noticeDate = picked;
      });
      HapticHelper.selection();
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = Supabase.instance.client.auth.currentUser;
    final author = user?.email ?? 'Admin';

    final notice = NoticeModel(
      id: _uuid.v4(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      date: _noticeDate,
      priority: _selectedPriority,
      category: _selectedCategory,
      author: author,
      isArchived: false,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(noticesNotifierProvider.notifier).createNotice(notice);
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notice created successfully'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating notice: ${e.toString()}'),
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
        title: Text('Create Notice', style: AppTextStyles.h2),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              FadeSlideWidget(
                delay: const Duration(milliseconds: 100),
                child: CustomButton(
                  text: 'Back to Notice Board',
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.pop(context),
                  type: ButtonType.secondary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Notice Information Section
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
                              Icons.campaign,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text('Notice Information', style: AppTextStyles.h3),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        CustomTextField(
                          label: 'Title *',
                          controller: _titleController,
                          hint: 'Enter notice title',
                          validator: (value) => Validators.required(value, fieldName: 'Title'),
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Content *',
                          controller: _contentController,
                          hint: 'Enter notice content',
                          maxLines: 6,
                          validator: (value) => Validators.required(value, fieldName: 'Content'),
                        ),
                        const SizedBox(height: 16),
                        
                        // Date Picker
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: CustomTextField(
                              label: 'Notice Date *',
                              controller: TextEditingController(
                                text: DateFormat('yyyy-MM-dd').format(_noticeDate),
                              ),
                              hint: 'Select date',
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Priority Dropdown
                        DropdownButtonFormField<NoticePriority>(
                          value: _selectedPriority,
                          decoration: const InputDecoration(
                            labelText: 'Priority *',
                            border: OutlineInputBorder(),
                          ),
                          items: NoticePriority.values.map((priority) {
                            String label;
                            switch (priority) {
                              case NoticePriority.low:
                                label = 'Low';
                                break;
                              case NoticePriority.medium:
                                label = 'Medium';
                                break;
                              case NoticePriority.high:
                                label = 'High';
                                break;
                            }
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(label),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPriority = value!;
                            });
                            HapticHelper.selection();
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Category Dropdown
                        DropdownButtonFormField<NoticeCategory>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category *',
                            border: OutlineInputBorder(),
                          ),
                          items: NoticeCategory.values.map((category) {
                            String label;
                            switch (category) {
                              case NoticeCategory.general:
                                label = 'General';
                                break;
                              case NoticeCategory.maintenance:
                                label = 'Maintenance';
                                break;
                              case NoticeCategory.event:
                                label = 'Event';
                                break;
                              case NoticeCategory.emergency:
                                label = 'Emergency';
                                break;
                            }
                            return DropdownMenuItem(
                              value: category,
                              child: Text(label),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                            HapticHelper.selection();
                          },
                        ),
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
                        text: 'Create Notice',
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

