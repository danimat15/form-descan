import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/survey_provider.dart';
import 'member_detail_dialog.dart';

class Blok4AnggotaWidget extends StatelessWidget {
  const Blok4AnggotaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SurveyProvider>(context);
    final survey = provider.activeSurvey!;
    final theme = Theme.of(context);

    return Column(
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
                    'Keterangan Anggota Keluarga',
                    style: theme.textTheme.titleLarge?.copyWith(color: theme.primaryColor),
                  ),
                  const SizedBox(height: 4),
                  const Text('Daftar seluruh anggota keluarga yang tinggal bersama.', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                provider.addFamilyMember();
                // Open the modal for the newly added member (last one in list)
                final newMember = survey.familyMembers.last;
                _openMemberDetails(context, newMember.id);
              },
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('ADD MEMBER'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        const Divider(height: 32),

        if (survey.familyMembers.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48.0),
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 48, color: theme.dividerColor),
                  const SizedBox(height: 12),
                  const Text(
                    'No family members added yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: provider.addFamilyMember,
                    child: const Text('Add the first member'),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: survey.familyMembers.length,
            itemBuilder: (context, index) {
              final member = survey.familyMembers[index];
              final name = member.nama.isNotEmpty ? member.nama : 'Member ${index + 1} (Name not set)';
              final gender = member.jenisKelamin == '1' ? 'Laki-laki' : 'Perempuan';
              final dob = member.tglLahir?.isNotEmpty == true ? member.tglLahir : 'DOB not set';
              final relationship = _getRelationshipLabel(member.hubunganKk);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    foregroundColor: theme.primaryColor,
                    child: Text('${member.noUrut}'),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$relationship • $gender'),
                      Text('DOB: $dob', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.teal),
                        tooltip: 'Edit details',
                        onPressed: () => _openMemberDetails(context, member.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        tooltip: 'Remove',
                        onPressed: () => provider.removeFamilyMember(member.id),
                      ),
                    ],
                  ),
                  onTap: () => _openMemberDetails(context, member.id),
                ),
              );
            },
          ),
      ],
    );
  }

  void _openMemberDetails(BuildContext context, String memberId) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Member Details',
      pageBuilder: (context, anim1, anim2) {
        return MemberDetailDialog(memberId: memberId);
      },
    );
  }

  String _getRelationshipLabel(String? relationshipCode) {
    switch (relationshipCode) {
      case '1':
        return 'Kepala Keluarga';
      case '2':
        return 'Istri/Suami';
      case '3':
        return 'Anak';
      case '4':
        return 'Menantu';
      case '5':
        return 'Cucu';
      case '6':
        return 'Orang Tua';
      case '7':
        return 'Mertua';
      case '8':
        return 'Famili';
      case '9':
      default:
        return 'Lainnya';
    }
  }
}
