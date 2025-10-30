import 'package:flutter/material.dart';
import '../models/book_file.dart';

class BookTile extends StatelessWidget {
  final BookFile book;
  final VoidCallback onTap;

  const BookTile({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildThumbnail(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: book.type == 'pdf'
                                  ? const Color(0xFFEDF2F7)
                                  : const Color(0xFFF0FFF4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              book.type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: book.type == 'pdf'
                                    ? const Color(0xFF4A5568)
                                    : const Color(0xFF38A169),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            book.sizeFormatted,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF718096),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Modified ${_formatDate(book.lastModified)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 48,
      height: 64,
      decoration: BoxDecoration(
        color: book.type == 'pdf'
            ? const Color(0xFFE53E3E).withValues(alpha: 0.1)
            : const Color(0xFF38A169).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        book.type == 'pdf' ? Icons.picture_as_pdf : Icons.book,
        color: book.type == 'pdf'
            ? const Color(0xFFE53E3E)
            : const Color(0xFF38A169),
        size: 24,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
