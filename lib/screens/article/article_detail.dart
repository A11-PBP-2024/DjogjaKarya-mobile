import 'package:flutter/material.dart';
import '/models/article.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart'; // Ganti dengan path model yang benar

class ArticleDetail extends StatelessWidget {
  final Article article;
  const ArticleDetail({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          myIconButton(Icons.bookmark_outline),
          myIconButton(Icons.favorite_border),
          myIconButton(Icons.share_outlined),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 30, right: 15, left: 15),
        child: ListView(
          children: [
            Text(
              article.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 17,
                  backgroundImage: NetworkImage(
                      "https://img.freepik.com/premium-photo/profile-picture-happy-young-caucasian-man-spectacles-show-confidence-leadership-headshot-portrait-smiling-millennial-male-glasses-posing-indoors-home-employment-success-concept_774935-1446.jpg"),
                ),
                const SizedBox(width: 8),
                Text("${article.author}, "),
                Text(
                  article.publicationDate,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 15,
              children: [
                likeShareButton(Icons.tag, "Tag: ${article.tags}"),
                likeShareButton(Icons.date_range, article.publicationDate),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                article.image.isNotEmpty
                    ? article.image
                    : 'https://via.placeholder.com/600',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                text: "",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
                children: [
                  TextSpan(
                    text: article.description,
                    style: const TextStyle(
                      fontSize: 18,
                      wordSpacing: 2,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              article.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Wrap likeShareButton(icon, title) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 5,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.black54,
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        )
      ],
    );
  }

  Padding myIconButton(icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.grey[200],
          child: IconButton(
            onPressed: () {},
            icon: Icon(
              icon,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
