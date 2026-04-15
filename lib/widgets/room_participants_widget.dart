import 'package:flutter/material.dart';
import '../models/room_participant.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class RoomParticipantsWidget extends StatelessWidget {
  final List<RoomParticipant> participants;
  final String ownerId;
  final bool compact;

  const RoomParticipantsWidget({
    Key? key,
    required this.participants,
    required this.ownerId,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: participants.length,
          itemBuilder: (_, i) => _AvatarBadge(
            participant: participants[i],
            isOwner: participants[i].userId == ownerId,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: participants.length,
      itemBuilder: (_, i) => _ParticipantTile(
        participant: participants[i],
        isOwner: participants[i].userId == ownerId,
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final RoomParticipant participant;
  final bool isOwner;

  const _AvatarBadge(
      {Key? key, required this.participant, required this.isOwner})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isOwner ? AppColors.accent : AppColors.primary,
            backgroundImage: participant.avatarUrl != null
                ? NetworkImage(participant.avatarUrl!)
                : null,
            child: participant.avatarUrl == null
                ? Text(
                    _initials(participant.displayName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          if (!participant.isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 1.5),
                ),
              ),
            )
          else
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final RoomParticipant participant;
  final bool isOwner;

  const _ParticipantTile(
      {Key? key, required this.participant, required this.isOwner})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor:
                isOwner ? AppColors.accent : AppColors.primary,
            backgroundImage: participant.avatarUrl != null
                ? NetworkImage(participant.avatarUrl!)
                : null,
            child: participant.avatarUrl == null
                ? Text(
                    _initials(participant.displayName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: participant.isOnline
                    ? AppColors.success
                    : AppColors.textSecondary,
                shape: BoxShape.circle,
                border:
                    Border.all(color: AppColors.background, width: 1.5),
              ),
            ),
          ),
        ],
      ),
      title: Row(
        children: [
          Text(participant.displayName, style: AppStyles.bodyMedium),
          if (isOwner) ...[
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Owner',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: participant.isOnline
          ? const Text('Online',
              style: TextStyle(color: AppColors.success, fontSize: 12))
          : const Text('Offline',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      trailing: participant.lastRollResult != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Last roll',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 10)),
                Text(
                  participant.lastRollResult.toString(),
                  style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold),
                ),
              ],
            )
          : null,
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}
