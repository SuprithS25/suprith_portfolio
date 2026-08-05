import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// Google Drive "view" links don't trigger a download — this is the
// direct-download form of the same file (extracted the file ID from
// the share link you gave me).
const String kResumeUrl =
    'https://www.dropbox.com/scl/fi/ik00bjyssjutfcmqmjc5r/SuprithResume1.pdf?rlkey=to43vybgjf7cld6swgvifkp02&st=9zuj37vf&e=1&dl=0';

// Your Formspree endpoint.
const String kFormspreeUrl = 'https://formspree.io/f/xwleeply';

void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatefulWidget {
  const PortfolioApp({super.key});

  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Suprith S | Portfolio',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      // Apple/Vercel Light Theme
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        cardColor: const Color(0xFFFFFFFF),
        primaryColor: const Color(0xFF000000),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF000000),
          secondary: Color(0xFF666666),
          surface: Color(0xFFFFFFFF),
        ),
        fontFamily: 'SF Pro Display',
      ),
      // Apple/Vercel Dark Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        cardColor: const Color(0xFF111111),
        primaryColor: const Color(0xFFFFFFFF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFFFFF),
          secondary: Color(0xFF888888),
          surface: Color(0xFF111111),
        ),
        fontFamily: 'SF Pro Display',
      ),
      home: PortfolioHomePage(
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

class PortfolioHomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const PortfolioHomePage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<PortfolioHomePage> createState() => _PortfolioHomePageState();
}

class _PortfolioHomePageState extends State<PortfolioHomePage> {
  final ScrollController _scrollController = ScrollController();

  // Section Keys for Smooth Scrolling
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();
  final GlobalKey _experienceKey = GlobalKey();
  final GlobalKey _skillsKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  // Contact Form Key & Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    // Fix: controllers were never disposed before, causing memory leaks.
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final response = await http.post(
        Uri.parse(kFormspreeUrl),
        headers: {'Accept': 'application/json'},
        body: {
          'name': _nameController.text,
          'email': _emailController.text,
          'message': _messageController.text,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully!')),
        );
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Something went wrong. Please try again.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Could not send message. Check your connection.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _launchUrl(String url) async {
    // Fix: launch failures are now caught and surfaced to the user instead
    // of throwing an unhandled exception from an onPressed callback.
    try {
      final Uri uri = Uri.parse(url);
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isDark = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        // Fix: withOpacity is deprecated in favor of withValues.
        backgroundColor:
            (isDark ? Colors.black : Colors.white).withValues(alpha: 0.8),
        elevation: 0,
        title: const Text(
          'Suprith S.',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        actions: [
          if (!isMobile) ...[
            TextButton(
                onPressed: () => _scrollToSection(_projectsKey),
                child: const Text('Projects')),
            TextButton(
                onPressed: () => _scrollToSection(_experienceKey),
                child: const Text('Experience')),
            TextButton(
                onPressed: () => _scrollToSection(_skillsKey),
                child: const Text('Skills')),
            TextButton(
                onPressed: () => _scrollToSection(_contactKey),
                child: const Text('Contact')),
          ],
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: isMobile
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    child: Text(
                      'Suprith S',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    title: const Text('Projects'),
                    onTap: () {
                      Navigator.pop(context);
                      _scrollToSection(_projectsKey);
                    },
                  ),
                  ListTile(
                    title: const Text('Experience'),
                    onTap: () {
                      Navigator.pop(context);
                      _scrollToSection(_experienceKey);
                    },
                  ),
                  ListTile(
                    title: const Text('Skills'),
                    onTap: () {
                      Navigator.pop(context);
                      _scrollToSection(_skillsKey);
                    },
                  ),
                  ListTile(
                    title: const Text('Contact'),
                    onTap: () {
                      Navigator.pop(context);
                      _scrollToSection(_contactKey);
                    },
                  ),
                ],
              ),
            )
          : null,
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HERO SECTION (Apple/Vercel Minimalist)
                Container(key: _heroKey),
                const SizedBox(height: 20),
                const Text(
                  'SUPRITH S',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                const TypingTextAnimation(
                  texts: [
                    'Cross-Platform Developer.',
                    'Flutter & Dart Engineer.',
                    'FinTech & Mobile Security Developer.',
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Detail-oriented Software Engineer specializing in building secure, scalable, '
                  'and responsive mobile applications with complex API integrations.',
                  style: TextStyle(
                    fontSize: 18,
                    // Fix: Color.fromARGB's first argument is alpha (0-255),
                    // not a color channel. The old value (9) made this text
                    // ~3.5% opaque and effectively invisible in dark mode.
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _scrollToSection(_contactKey),
                      icon: const Icon(Icons.mail_outline, size: 18),
                      label: const Text('Get in Touch'),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _launchUrl(kResumeUrl),
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Download Resume'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.code),
                      onPressed: () =>
                          _launchUrl('https://github.com/SuprithS25'),
                      tooltip: 'GitHub',
                    ),
                    IconButton(
                      icon: const Icon(Icons.work_outline),
                      onPressed: () =>
                          _launchUrl('https://linkedin.com/in/suprith25'),
                      tooltip: 'LinkedIn',
                    ),
                  ],
                ),

                const SizedBox(height: 80),

                // 2. FEATURED PROJECTS SECTION
                Container(key: _projectsKey),
                const SectionTitle(
                    title: 'Projects', subtitle: 'Here are some of my major projects.'),
                const SizedBox(height: 24),

                // Project 1: ApexPe (Velorantra Collaboration)
                AnimatedProjectCard(
                  title: 'ApexPe — B2B FinTech Payment Application',
                  subtitle:
                      'Built in direct collaboration with Velorantra Growth Company during a 4-month internship.',
                  overview:
                      'Architected a cross-platform corporate credit limit manager and vendor payout engine.',
                  contributions: [
                    'Engineered dynamic UI dashboards and responsive payment flows in Flutter.',
                    'Integrated secure REST APIs for financial transaction handling and ledger updates.',
                    'Simulated edge cases using MockAPI to verify app behavior under network delays.',
                  ],
                  challenges:
                      'Handled asynchronous state sync across complex payment widgets during high-frequency data shifts.',
                  tags: const [
                    'Flutter',
                    'Dart',
                    'FinTech',
                    'Velorantra',
                    'MockAPI',
                    'REST API'
                  ],
                  isDark: isDark,
                  repoUrl: 'https://github.com/SuprithS25/mapex',
                  onOpenRepo: _launchUrl,
                ),

                const SizedBox(height: 20),

                // Project 2: Malicious App Detector
                AnimatedProjectCard(
                  title: 'Malicious Mobile Application Detector',
                  subtitle: 'Security Scanner & AI Assistant',
                  overview:
                      'Cross-references installed app package signatures against threat databases and features a real-time AI security chatbot.',
                  contributions: [
                    'Extracted native Android application metadata and analyzed package hash signatures.',
                    'Integrated an AI chatbot engine to explain scan findings into simple user advice.',
                  ],
                  challenges:
                      'Resolved thread blocking during heavy package processing by offloading scanning to Flutter Isolates.',
                  tags: const [
                    'Flutter',
                    'Security',
                    'AI Chatbot',
                    'Isolates',
                    'Dart'
                  ],
                  isDark: isDark,
                  repoUrl: 'https://github.com/SuprithS25/MAD',
                  onOpenRepo: _launchUrl,
                ),

                const SizedBox(height: 20),

                // Project 3: Attendance Leave Manager
                AnimatedProjectCard(
                  title: 'Attendance Leave Manager',
                  subtitle:
                      'Full-Stack HR Attendance & Leave Management System (Epic Minds)',
                  overview:
                      'Built an HRMS web app for clock-in/out tracking, leave requests, and admin approvals, with a documented REST API and MySQL schema.',
                  contributions: [
                    'Designed a component-driven React + TypeScript frontend with dedicated modules for attendance, leave, auth, and admin dashboards.',
                    'Defined a full REST API surface (auth, attendance, leave, users) with structured error codes and documented request/response contracts.',
                    'Modeled a relational MySQL schema covering users, roles, attendance, leave requests, and sessions, with an ER diagram for reference.',
                    'Built an in-app interactive API testing interface for exercising every endpoint during development.',
                  ],
                  challenges:
                      'Structured the API layer so the mock localStorage-backed implementation could later be swapped for real HTTP calls to a MySQL backend with minimal frontend changes.',
                  tags: const [
                    'React',
                    'TypeScript',
                    'Vite',
                    'Tailwind CSS',
                    'MySQL',
                    'REST API'
                  ],
                  isDark: isDark,
                  repoUrl:
                      'https://github.com/SuprithS25/Attendance-Leave-Manager',
                  onOpenRepo: _launchUrl,
                ),

                const SizedBox(height: 80),

                // 3. EXPERIENCE TIMELINE SECTION
                Container(key: _experienceKey),
                const SectionTitle(
                    title: 'Experience', subtitle: 'Work history & internships.'),
                const SizedBox(height: 24),

                TimelineTile(
                  isDark: isDark,
                  company: 'Velorantra Growth Company',
                  role: 'Software Developer Intern (4 Months)',
                  duration: 'FinTech App Development',
                  details: [
                    'Collaborated closely with engineering teams to build ApexPe from architectural design to integration.',
                    'Engineered custom, scalable UI widgets and integrated backend API routes for financial execution.',
                    'Conducted rigorous integration testing for transaction edge cases.',
                  ],
                ),
                TimelineTile(
                  isDark: isDark,
                  company: 'Plentra Technologies Pvt Ltd',
                  role: 'Software Developer Intern',
                  duration: 'July 2025 – August 2025',
                  details: [
                    'Developed cross-platform mobile features using Flutter and Dart in clean architecture.',
                    'Transformed Figma designs into pixel-perfect responsive layouts.',
                    'Debugged device-specific layout overflows using Flutter DevTools.',
                  ],
                ),

                const SizedBox(height: 80),

                // 4. SKILLS PROGRESS SECTION
                Container(key: _skillsKey),
                const SectionTitle(
                    title: 'Skills & Expertise', subtitle: 'Technologies I work with.'),
                const SizedBox(height: 24),

                SkillProgressBar(
                    skill: 'Flutter & Dart', percentage: 0.90, isDark: isDark),
                SkillProgressBar(
                    skill: 'Java & OOP', percentage: 0.80, isDark: isDark),
                SkillProgressBar(
                    skill: 'REST API Integration & State Management',
                    percentage: 0.85,
                    isDark: isDark),
                SkillProgressBar(
                    skill: 'JavaScript, HTML & CSS',
                    percentage: 0.75,
                    isDark: isDark),
                SkillProgressBar(
                    skill: 'MySQL & Databases',
                    percentage: 0.70,
                    isDark: isDark),
                SkillProgressBar(
                    skill: 'Git, C#, & Figma UI Design',
                    percentage: 0.75,
                    isDark: isDark),

                const SizedBox(height: 80),

                // 5. CONTACT FORM SECTION
                Container(key: _contactKey),
                const SectionTitle(
                    title: 'Contact', subtitle: 'Let\'s build something together.'),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF111111) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF222222) : const Color(0xFFEEEEEE),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter your name'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || !value.contains('@')
                              ? 'Please enter a valid email'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _messageController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Message',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter your message'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.white : Colors.black,
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                          ),
                          onPressed: _isSending ? null : _sendMessage,
                          child: _isSending
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        isDark ? Colors.black : Colors.white),
                                  ),
                                )
                              : const Text('Send Message'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 80),
                Center(
                  child: Text(
                    '© 2026 Suprith S. Built with Flutter Web.',
                    style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- HELPER COMPONENTS ---

// 1. Typing Effect Animation
class TypingTextAnimation extends StatefulWidget {
  final List<String> texts;
  const TypingTextAnimation({super.key, required this.texts});

  @override
  State<TypingTextAnimation> createState() => _TypingTextAnimationState();
}

class _TypingTextAnimationState extends State<TypingTextAnimation> {
  String _displayedText = "";
  int _textIndex = 0;
  int _charIndex = 0;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _animateTyping();
  }

  void _animateTyping() async {
    while (mounted) {
      final currentText = widget.texts[_textIndex];
      if (_isDeleting) {
        _displayedText = currentText.substring(0, _charIndex--);
      } else {
        _displayedText = currentText.substring(0, _charIndex++);
      }

      if (mounted) setState(() {});

      int delay = _isDeleting ? 40 : 80;
      if (!_isDeleting && _charIndex == currentText.length + 1) {
        delay = 1500; // Pause at full word
        _isDeleting = true;
        _charIndex = currentText.length;
      } else if (_isDeleting && _charIndex == 0) {
        _isDeleting = false;
        _textIndex = (_textIndex + 1) % widget.texts.length;
      }

      await Future.delayed(Duration(milliseconds: delay));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Text(
        '$_displayedText|',
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
        ),
      ),
    );
  }
}

// 2. Section Title
class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const SectionTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
              fontSize: 14, color: isDark ? Colors.white60 : Colors.black54),
        ),
      ],
    );
  }
}

// 3. Animated Project Card (Vercel Style)
class AnimatedProjectCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String overview;
  final List<String> contributions;
  final String challenges;
  final List<String> tags;
  final bool isDark;
  // URL to open when the card is clicked/tapped (e.g. the GitHub repo).
  final String? repoUrl;
  // Called with repoUrl when the card is tapped, if repoUrl is set.
  final ValueChanged<String>? onOpenRepo;

  const AnimatedProjectCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.overview,
    required this.contributions,
    required this.challenges,
    required this.tags,
    required this.isDark,
    this.repoUrl,
    this.onOpenRepo,
  });

  @override
  State<AnimatedProjectCard> createState() => _AnimatedProjectCardState();
}

class _AnimatedProjectCardState extends State<AnimatedProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final subtleColor = widget.isDark ? Colors.white60 : Colors.black54;
    final isClickable = widget.repoUrl != null && widget.onOpenRepo != null;

    return MouseRegion(
      cursor:
          isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: isClickable
            ? () => widget.onOpenRepo!(widget.repoUrl!)
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF111111) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? (widget.isDark ? Colors.white54 : Colors.black)
                  : (widget.isDark
                      ? const Color(0xFF222222)
                      : const Color(0xFFEEEEEE)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3),
                    ),
                  ),
                  if (isClickable) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_outward, size: 18, color: subtleColor),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: subtleColor),
              ),
              const SizedBox(height: 12),
              Text(widget.overview,
                  style: const TextStyle(fontSize: 14, height: 1.4)),
              const SizedBox(height: 12),
              ...widget.contributions.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(
                            child: Text(c,
                                style: TextStyle(
                                    fontSize: 13, color: subtleColor))),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
              Text(
                '⚡ Challenge: ${widget.challenges}',
                style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: subtleColor),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.tags
                    .map((t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? const Color(0xFF222222)
                                : const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child:
                              Text(t, style: const TextStyle(fontSize: 11)),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 4. Timeline Tile for Experience
class TimelineTile extends StatelessWidget {
  final bool isDark;
  final String company;
  final String role;
  final String duration;
  final List<String> details;

  const TimelineTile({
    super.key,
    required this.isDark,
    required this.company,
    required this.role,
    required this.duration,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final subtleColor = isDark ? Colors.white60 : Colors.black54;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(company,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text('$role • $duration',
                    style: TextStyle(fontSize: 13, color: subtleColor)),
                const SizedBox(height: 8),
                ...details.map((d) => Text('• $d',
                    style: TextStyle(
                        fontSize: 13, height: 1.4, color: subtleColor))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 5. Skill Progress Bar
class SkillProgressBar extends StatelessWidget {
  final String skill;
  final double percentage;
  final bool isDark;

  const SkillProgressBar({
    super.key,
    required this.skill,
    required this.percentage,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final subtleColor = isDark ? Colors.white60 : Colors.black54;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(skill,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              Text('${(percentage * 100).toInt()}%',
                  style: TextStyle(fontSize: 12, color: subtleColor)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor:
                  isDark ? const Color(0xFF222222) : const Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}