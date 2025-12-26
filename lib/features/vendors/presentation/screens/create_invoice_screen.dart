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
import '../../data/models/vendor_model.dart';
import '../../providers/vendors_provider.dart';
import '../../../finance/data/models/vendor_invoice_model.dart';
import '../../../finance/providers/vendor_invoices_provider.dart';
import '../../../finance/data/repositories/vendor_invoice_repository.dart';
import '../../data/repositories/vendor_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  final VendorModel vendor;

  const CreateInvoiceScreen({
    super.key,
    required this.vendor,
  });

  @override
  ConsumerState<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _itemChargesController = TextEditingController();
  final _taxController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  final List<InvoiceItem> _invoiceItems = [];
  bool _isLoading = false;
  final _uuid = const Uuid();
  final VendorInvoiceRepository _invoiceRepository = VendorInvoiceRepository();
  final VendorRepository _vendorRepository = VendorRepository();

  @override
  void initState() {
    super.initState();
    // Generate invoice number
    _invoiceNumberController.text = 'INV-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _itemDescriptionController.dispose();
    _itemChargesController.dispose();
    _taxController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectInvoiceDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _invoiceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _invoiceDate) {
      setState(() {
        _invoiceDate = picked;
      });
      HapticHelper.selection();
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: _invoiceDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
      HapticHelper.selection();
    }
  }

  void _addInvoiceItem() {
    if (_itemDescriptionController.text.isNotEmpty && 
        _itemChargesController.text.isNotEmpty) {
      final charges = double.tryParse(_itemChargesController.text.trim()) ?? 0.0;
      if (charges > 0) {
        HapticHelper.light();
        setState(() {
          _invoiceItems.add(InvoiceItem(
            srNo: _invoiceItems.length + 1,
            description: _itemDescriptionController.text.trim(),
            charges: charges,
          ));
          _itemDescriptionController.clear();
          _itemChargesController.clear();
        });
      }
    }
  }

  void _removeInvoiceItem(int index) {
    HapticHelper.light();
    setState(() {
      _invoiceItems.removeAt(index);
      // Re-number items
      for (int i = 0; i < _invoiceItems.length; i++) {
        _invoiceItems[i] = InvoiceItem(
          srNo: i + 1,
          description: _invoiceItems[i].description,
          charges: _invoiceItems[i].charges,
        );
      }
    });
  }

  double _calculateSubtotal() {
    return _invoiceItems.fold<double>(0, (sum, item) => sum + item.charges);
  }

  double _calculateTax() {
    final taxPercent = double.tryParse(_taxController.text.trim()) ?? 0.0;
    return _calculateSubtotal() * (taxPercent / 100);
  }

  double _calculateTotal() {
    return _calculateSubtotal() + _calculateTax();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_invoiceItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one invoice item'),
          backgroundColor: AppColors.warningYellow,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final subtotal = _calculateSubtotal();
      final tax = _calculateTax();
      final total = _calculateTotal();

      // Create invoice
      final invoice = VendorInvoiceModel(
        id: _uuid.v4(),
        vendorId: widget.vendor.id,
        invoiceNumber: _invoiceNumberController.text.trim(),
        invoiceDate: _invoiceDate,
        dueDate: _dueDate,
        items: _invoiceItems,
        subtotal: subtotal,
        tax: tax,
        total: total,
        status: InvoiceStatus.pending,
        notes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create invoice in database
      await _invoiceRepository.createInvoice(invoice);

      // Update vendor balances
      final currentVendor = await _vendorRepository.getVendorById(widget.vendor.id);
      if (currentVendor != null) {
        final updatedVendor = VendorModel(
          id: currentVendor.id,
          vendorName: currentVendor.vendorName,
          email: currentVendor.email,
          phoneNumber: currentVendor.phoneNumber,
          workDetails: currentVendor.workDetails,
          totalBill: currentVendor.totalBill + total,
          paidBill: currentVendor.paidBill,
          outstandingBill: currentVendor.outstandingBill + total,
          createdAt: currentVendor.createdAt,
          updatedAt: DateTime.now(),
        );
        await _vendorRepository.updateVendor(updatedVendor);
      }

      // Refresh providers
      ref.invalidate(vendorInvoicesProvider);
      ref.invalidate(vendorsNotifierProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invoice created successfully'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating invoice: ${e.toString()}'),
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
    final subtotal = _calculateSubtotal();
    final tax = _calculateTax();
    final total = _calculateTotal();

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
          'Create Invoice',
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
                  text: 'Back to Vendors',
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.pop(context),
                  type: ButtonType.secondary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Vendor Information
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
                              Icons.business,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text('Vendor Information', style: AppTextStyles.h3),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildInfoRow('Vendor Name', widget.vendor.vendorName),
                        const SizedBox(height: 16),
                        _buildInfoRow('Current Total Bill', '₹${widget.vendor.totalBill.toStringAsFixed(2)}'),
                        const SizedBox(height: 16),
                        _buildInfoRow('Outstanding', '₹${widget.vendor.outstandingBill.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Invoice Details
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
                              Icons.receipt,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text('Invoice Details', style: AppTextStyles.h3),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          label: 'Invoice Number *',
                          controller: _invoiceNumberController,
                          validator: (value) => Validators.required(value, fieldName: 'Invoice Number'),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _selectInvoiceDate(context),
                          child: AbsorbPointer(
                            child: CustomTextField(
                              label: 'Invoice Date *',
                              controller: TextEditingController(
                                text: DateFormat('dd/MM/yyyy').format(_invoiceDate),
                              ),
                              suffixIcon: const Icon(Icons.calendar_today, color: AppColors.textTertiary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _selectDueDate(context),
                          child: AbsorbPointer(
                            child: CustomTextField(
                              label: 'Due Date *',
                              controller: TextEditingController(
                                text: DateFormat('dd/MM/yyyy').format(_dueDate),
                              ),
                              suffixIcon: const Icon(Icons.calendar_today, color: AppColors.textTertiary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Invoice Items
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
                              Icons.list,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text('Invoice Items', style: AppTextStyles.h3),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: CustomTextField(
                                label: 'Description',
                                controller: _itemDescriptionController,
                                hint: 'Item description',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                label: 'Amount (₹)',
                                controller: _itemChargesController,
                                keyboardType: TextInputType.number,
                                hint: '0.00',
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: Icon(Icons.add_circle, color: AppColors.primaryPurple),
                              onPressed: _addInvoiceItem,
                              tooltip: 'Add Item',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_invoiceItems.isNotEmpty) ...[
                          const Divider(),
                          const SizedBox(height: 16),
                          ..._invoiceItems.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.srNo}. ${item.description}',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ),
                                  Text(
                                    '₹${item.charges.toStringAsFixed(2)}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.errorRed),
                                    onPressed: () => _removeInvoiceItem(index),
                                    tooltip: 'Remove',
                                  ),
                                ],
                              ),
                            );
                          }),
                          const Divider(),
                          const SizedBox(height: 16),
                          _buildInfoRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  label: 'Tax (%)',
                                  controller: _taxController,
                                  keyboardType: TextInputType.number,
                                  hint: '0',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Text(
                                    'Tax Amount: ₹${tax.toStringAsFixed(2)}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            'Total',
                            '₹${total.toStringAsFixed(2)}',
                            isTotal: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Notes
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
                              Icons.note,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text('Notes', style: AppTextStyles.h3),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Additional Notes',
                          controller: _notesController,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              FadeSlideWidget(
                delay: const Duration(milliseconds: 600),
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
                        text: 'Create Invoice',
                        icon: Icons.receipt,
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

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label:',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: isTotal
                ? AppTextStyles.h3.copyWith(color: AppColors.primaryPurple)
                : AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}
