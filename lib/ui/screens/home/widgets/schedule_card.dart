import 'package:flutter/material.dart';
import 'package:study_scheduler/data/models/schedule.dart';

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback? onTap;

  const ScheduleCard({
    super.key,
    required this.schedule,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(
            color: schedule.isActive == true 
                ? Colors.transparent 
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Color indicator
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: schedule.scheduleColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            
            // Schedule info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: schedule.isActive == true ? Colors.black : Colors.grey,
                    ),
                  ),
                  if (schedule.description != null && schedule.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        schedule.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            
            // Status toggle
            Switch(
              value: schedule.isActive == 1,
              onChanged: null, // Make it non-interactive in this card
              activeColor: schedule.scheduleColor,
            ),
          ],
        ),
      ),
    );
  }
}