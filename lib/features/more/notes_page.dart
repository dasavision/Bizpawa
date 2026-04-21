import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizpawa/core/state/business_state.dart';
import 'package:bizpawa/core/services/notification_service.dart';

const _kNavy = Color(0xFF1B2E6B);
const _kAmber = Color(0xFFF59E0B);

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final biz = context.watch<BusinessState>();
    final notes = biz.notes;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBEB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Kumbukumbu zangu',
            style: TextStyle(
                color: _kNavy, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: _kNavy),
            onPressed: () => _showAddNoteSheet(context),
          ),
        ],
      ),
      body: notes.isEmpty
          ? _emptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notes.length,
              itemBuilder: (_, i) {
                final note = notes[i];
                return GestureDetector(
                  onTap: () =>
                      _showNoteDetail(context, note, biz),
                  onLongPress: () =>
                      _confirmDelete(context, note.id, biz),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _noteColor(i),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        if (note.title.isNotEmpty) ...[
                          Text(note.title,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _kNavy)),
                          const SizedBox(height: 6),
                        ],
                        Text(
                          note.content,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${note.createdAt.day}/${note.createdAt.month}/${note.createdAt.year} • ${note.createdAt.hour.toString().padLeft(2, '0')}:${note.createdAt.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_note',
        backgroundColor: _kAmber,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => _showAddNoteSheet(context),
      ),
    );
  }

  Color _noteColor(int index) {
    final colors = [
      Colors.white,
      const Color(0xFFFEF9C3),
      const Color(0xFFDCFCE7),
      const Color(0xFFDBEAFE),
      const Color(0xFFFFE4E6),
    ];
    return colors[index % colors.length];
  }

  Widget _emptyState(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📝',
                style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text('Hakuna kumbukumbu bado',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _kNavy)),
            const SizedBox(height: 8),
            Text('Bonyeza + kuandika ya kwanza',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500)),
          ],
        ),
      );

  void _showNoteDetail(BuildContext context, AppNote note,
      BusinessState biz) {
    final titleCtrl =
        TextEditingController(text: note.title);
    final contentCtrl =
        TextEditingController(text: note.content);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Hariri Kumbukumbu',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _kNavy)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red),
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDelete(context, note.id, biz);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  hintText: 'Kichwa (hiari)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Andika hapa...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kAmber,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    biz.updateNote(AppNote(
                      id: note.id,
                      title: titleCtrl.text.trim(),
                      content: contentCtrl.text.trim(),
                      createdAt: note.createdAt,
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text('Hifadhi Mabadiliko',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddNoteSheet(BuildContext context) {
    final biz = context.read<BusinessState>();
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Kumbukumbu Mpya',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _kNavy)),
              const SizedBox(height: 20),
              TextField(
                controller: titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Kichwa (hiari)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                maxLines: 6,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Andika hapa...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kAmber,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (contentCtrl.text.trim().isEmpty) {
                      return;
                    }
                    biz.addNote(AppNote(
                      id: DateTime.now()
                          .millisecondsSinceEpoch
                          .toString(),
                      title: titleCtrl.text.trim(),
                      content: contentCtrl.text.trim(),
                      createdAt: DateTime.now(),
                    ));
                    Navigator.pop(context);
                    NotificationService.show(
                      context: context,
                      message: 'Kumbukumbu imehifadhiwa!',
                      type: NotificationType.success,
                    );
                  },
                  child: const Text('Hifadhi',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id,
      BusinessState biz) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Futa Kumbukumbu?',
            style: TextStyle(
                color: _kNavy, fontWeight: FontWeight.bold)),
        content: const Text(
            'Kumbukumbu hii itafutwa kabisa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ghairi'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
            onPressed: () {
              biz.deleteNote(id);
              Navigator.pop(context);
            },
            child: const Text('Futa'),
          ),
        ],
      ),
    );
  }
}