import 'package:flutter/material.dart';
import '../models/survey_model.dart';
import '../services/storage_service.dart';
import '../services/pdf_export_service.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> with TickerProviderStateMixin {
  int _currentStep = 0;
  final SurveyData _surveyData = SurveyData();
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  // List data
  final List<String> _pekerjaanList = [
    'Mahasiswa',
    'Karyawan Swasta',
    'PNS',
    'Wiraswasta',
    'Freelancer',
    'Pelajar',
    'Ibu Rumah Tangga',
    'Lainnya'
  ];

  final List<String> _hobiList = [
    'Membaca',
    'Olahraga',
    'Musik',
    'Traveling',
    'Memasak',
    'Fotografi',
    'Programming',
    'Menonton Film',
    'Berkebun',
    'Game'
  ];

  final List<String> _kepuasanList = [
    'Sangat Puas',
    'Puas',
    'Cukup Puas',
    'Kurang Puas',
    'Tidak Puas'
  ];

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadSavedData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    try {
      final savedData = await StorageService.loadSurveyData();
      if (savedData != null) {
        setState(() {
          _surveyData.nama = savedData['nama'] ?? '';
          _surveyData.umur = savedData['umur'] ?? 0;
          _surveyData.pekerjaan = savedData['pekerjaan'] ?? '';
          _surveyData.hobi = List<String>.from(savedData['hobi'] ?? []);
          _surveyData.tingkatKepuasan = savedData['tingkatKepuasan'] ?? '';
          _surveyData.feedback = savedData['feedback'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading saved data: $e');
    }
  }

  Future<void> _autoSaveData() async {
    try {
      await StorageService.saveSurveyData(_surveyData.toJson());
    } catch (e) {
      print('Error auto-saving: $e');
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_formKeys[_currentStep].currentState!.validate()) {
        _formKeys[_currentStep].currentState!.save();
        _autoSaveData();
        
        _animationController.reverse().then((_) {
          setState(() {
            _currentStep++;
          });
          _animationController.forward();
        });
      }
    } else {
      _submitSurvey();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _animationController.reverse().then((_) {
        setState(() {
          _currentStep--;
        });
        _animationController.forward();
      });
    }
  }

  void _goToStep(int step) {
    _animationController.reverse().then((_) {
      setState(() {
        _currentStep = step;
      });
      _animationController.forward();
    });
  }

  void _submitSurvey() async {
    try {
      await StorageService.saveSurveyData(_surveyData.toJson());
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Survey Selesai!'),
          content: const Text('Terima kasih telah mengisi survey. '
              'Data Anda telah berhasil disimpan.'),
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Lihat Ringkasan'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Selesai'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error menyimpan data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Form'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              _previousStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (_currentStep == 3)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _exportToPdf(),
              tooltip: 'Export PDF',
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _autoSaveData,
            tooltip: 'Simpan',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Progress Indicator
            _buildProgressIndicator(),
            const SizedBox(height: 20),
            
            // Animated Step Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      child: child,
                    ),
                  );
                },
                child: _buildStepContent(),
              ),
            ),
            
            // Navigation Buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        // Step Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStepLabel(0, 'Data Diri'),
            _buildStepLabel(1, 'Pertanyaan'),
            _buildStepLabel(2, 'Feedback'),
            _buildStepLabel(3, 'Ringkasan'),
          ],
        ),
        const SizedBox(height: 10),
        
        // Progress Bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            alignment: Alignment(
              -1.0 + (2.0 / 3.0 * _currentStep),
              0,
            ),
            child: Container(
              width: 100,
              height: 8,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.green],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLabel(int step, String label) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;
    
    return GestureDetector(
      onTap: step <= _currentStep ? () => _goToStep(step) : null,
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.blue
                  : isCompleted
                      ? Colors.green
                      : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.blue : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildSummary();
      default:
        return Container();
    }
  }

  Widget _buildStep1() {
    return Form(
      key: _formKeys[0],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Diri',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Mohon isi data diri Anda dengan benar',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person),
                hintText: 'Masukkan nama lengkap',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama harus diisi';
                }
                if (value.length < 3) {
                  return 'Nama minimal 3 karakter';
                }
                return null;
              },
              onSaved: (value) => _surveyData.nama = value!,
              initialValue: _surveyData.nama,
              onChanged: (value) => _surveyData.nama = value,
            ),
            const SizedBox(height: 20),
            
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Umur',
                prefixIcon: Icon(Icons.calendar_today),
                suffixText: 'tahun',
                hintText: 'Masukkan umur',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Umur harus diisi';
                }
                final umur = int.tryParse(value);
                if (umur == null || umur < 1 || umur > 120) {
                  return 'Masukkan umur yang valid (1-120)';
                }
                return null;
              },
              onSaved: (value) => _surveyData.umur = int.parse(value!),
              initialValue: _surveyData.umur > 0 ? _surveyData.umur.toString() : '',
              onChanged: (value) {
                final umur = int.tryParse(value);
                if (umur != null) _surveyData.umur = umur;
              },
            ),
            const SizedBox(height: 20),
            
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Pekerjaan',
                prefixIcon: Icon(Icons.work),
                hintText: 'Pilih pekerjaan',
              ),
              value: _surveyData.pekerjaan.isNotEmpty ? _surveyData.pekerjaan : null,
              items: _pekerjaanList.map((pekerjaan) {
                return DropdownMenuItem(
                  value: pekerjaan,
                  child: Text(pekerjaan),
                );
              }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Pilih pekerjaan';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _surveyData.pekerjaan = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKeys[1],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pertanyaan Survey',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Jawab pertanyaan berikut sesuai dengan pengalaman Anda',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            
            // Hobi
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Apa hobi Anda?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Pilih satu atau lebih hobi yang sesuai'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _hobiList.map((hobi) {
                        final isSelected = _surveyData.hobi.contains(hobi);
                        return FilterChip(
                          label: Text(hobi),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _surveyData.hobi.add(hobi);
                              } else {
                                _surveyData.hobi.remove(hobi);
                              }
                            });
                          },
                          selectedColor: Colors.blue.withOpacity(0.2),
                          checkmarkColor: Colors.blue,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Tingkat Kepuasan
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bagaimana tingkat kepuasan Anda?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: _kepuasanList.map((kepuasan) {
                        return RadioListTile<String>(
                          title: Text(kepuasan),
                          value: kepuasan,
                          groupValue: _surveyData.tingkatKepuasan,
                          onChanged: (value) {
                            setState(() {
                              _surveyData.tingkatKepuasan = value!;
                            });
                          },
                          activeColor: Colors.blue,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return Form(
      key: _formKeys[2],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feedback',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Berikan kritik dan saran untuk perbaikan kami',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kritik dan Saran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      maxLines: 8,
                      decoration: const InputDecoration(
                        hintText: 'Tulis feedback Anda di sini...\n\n'
                            'Contoh:\n'
                            '• Fitur yang saya suka\n'
                            '• Kendala yang ditemui\n'
                            '• Saran perbaikan\n'
                            '• Harapan ke depan',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Feedback harus diisi';
                        }
                        if (value.length < 20) {
                          return 'Feedback minimal 20 karakter';
                        }
                        return null;
                      },
                      onSaved: (value) => _surveyData.feedback = value!,
                      initialValue: _surveyData.feedback,
                      onChanged: (value) => _surveyData.feedback = value,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.info, size: 16, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          '${_surveyData.feedback.length} karakter',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Tips
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Feedback yang jelas dan konstruktif akan sangat membantu kami '
                      'dalam meningkatkan layanan.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Survey',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Periksa kembali data yang telah Anda isi',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          
          // Data Diri
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 Data Diri',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  _buildSummaryItem('Nama Lengkap', _surveyData.nama),
                  _buildSummaryItem('Umur', '${_surveyData.umur} tahun'),
                  _buildSummaryItem('Pekerjaan', _surveyData.pekerjaan),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Hasil Survey
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 Hasil Survey',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  _buildSummaryItem('Hobi', _surveyData.hobi.join(', ')),
                  _buildSummaryItem('Tingkat Kepuasan', _surveyData.tingkatKepuasan),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Feedback
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💬 Feedback',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _surveyData.feedback.isNotEmpty
                          ? _surveyData.feedback
                          : 'Tidak ada feedback',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _exportToPdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export ke PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Data Survey'),
                        content: SingleChildScrollView(
                          child: Text(_surveyData.toString()),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.preview),
                  label: const Text('Lihat Data Lengkap'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : '-',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          if (_currentStep > 0)
            ElevatedButton(
              onPressed: _previousStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back, size: 18),
                  SizedBox(width: 8),
                  Text('Kembali'),
                ],
              ),
            )
          else
            const SizedBox(width: 100),
          
          // Next/Submit Button
          ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: Row(
              children: [
                Text(
                  _currentStep < 3 ? 'Lanjut' : 'Submit Survey',
                  style: const TextStyle(fontSize: 16),
                ),
                if (_currentStep < 3) const SizedBox(width: 8),
                if (_currentStep < 3)
                  const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPdf() async {
    try {
      await PdfExportService.exportToPdf(
        data: _surveyData,
        context: context,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}