import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:image_picker/image_picker.dart';

const green = Color(0xFF0BBF72);
const darkGreen = Color(0xFF003E2F);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const EmoveApp());
}

class EmoveApp extends StatelessWidget {
  const EmoveApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'eMove',
    themeMode: ThemeMode.light,
    theme: ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: green),
      scaffoldBackgroundColor: Colors.white,
      canvasColor: Colors.white,
      useMaterial3: true,
    ),
    home: const SplashScreen(),
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoPosition;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoPosition = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _logoScale = Tween<double>(begin: 1, end: .58).animate(_logoPosition);
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      await _controller.forward();
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, animation, __) => const CreateAccountScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _logoPosition,
            builder: (context, child) => Align(
              alignment: Alignment(0, 0.08 - (_logoPosition.value * 0.92)),
              child: Transform.scale(scale: _logoScale.value, child: child),
            ),
            child: const EmoveLogo(width: 340, height: 76),
          ),
        ),
      );
}

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});
  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool obscure = true;
  final _scrollController = ScrollController();
  final _emailKey = GlobalKey();
  final _passwordKey = GlobalKey();

  void _reveal(GlobalKey key) {
    void animateToField() {
      final target = key.currentContext;
      if (target == null) return;
      Scrollable.ensureVisible(
        target,
        alignment: 0.22,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => animateToField());
    Future.delayed(const Duration(milliseconds: 300), animateToField);
    Future.delayed(const Duration(milliseconds: 650), animateToField);
  }

  void _revealEmail() => _reveal(_emailKey);
  void _revealPassword() => _reveal(_passwordKey);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: true,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          controller: _scrollController,
          physics: MediaQuery.of(context).viewInsets.bottom > 0
              ? const ClampingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                maxWidth: 390,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Center(child: EmoveLogo()),
                  const SizedBox(height: 14),
                  const Text(
                    'Acesse sua conta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Entre para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Text(
                      'G',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFF4285F4),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    label: const Text('Continuar com o Google'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black54, width: 1.2),
                      minimumSize: const Size.fromHeight(42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(36),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const OrDivider(),
                  const SizedBox(height: 12),
                  const FieldLabel('E-mail'),
                  const SizedBox(height: 6),
                  InputField(
                    key: _emailKey,
                    hint: 'seu@email.com',
                    icon: Icons.mail_outline,
                    onTap: _revealEmail,
                  ),
                  const SizedBox(height: 12),
                  const FieldLabel('Senha'),
                  const SizedBox(height: 6),
                  InputField(
                    key: _passwordKey,
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    obscureText: obscure,
                    onTap: _revealPassword,
                    suffix: IconButton(
                      onPressed: () => setState(() => obscure = !obscure),
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 29,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        overlayColor: Colors.transparent,
                      ),
                      child: const Text(
                        'Esqueci minha senha',
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PassengerShell()),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(36),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Entrar'),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Ainda não tem uma conta? ',
                          style: TextStyle(color: Colors.black54, fontSize: 15),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Criar conta',
                            style: TextStyle(
                              color: darkGreen,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class PassengerShell extends StatefulWidget {
  final int initialIndex;
  const PassengerShell({super.key, this.initialIndex = 0});
  @override
  State<PassengerShell> createState() => _PassengerShellState();
}

class _PassengerShellState extends State<PassengerShell> {
  late int index = widget.initialIndex;

  static const pages = [
    PassengerHome(),
    PassengerTrips(),
    PassengerWallet(),
    PassengerProfile(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showPermissionIntro());
  }

  Future<void> _showPermissionIntro() async {
    if (!mounted) return;
    final continueSetup = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permissões do eMove'),
        content: const Text('Para encontrar corridas próximas, avisar sobre suas viagens e proteger sua conta, o eMove precisa de algumas permissões do aparelho.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Agora não')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: darkGreen, foregroundColor: Colors.white), onPressed: () => Navigator.of(context).pop(true), child: const Text('Continuar')),
        ],
      ),
    );
    if (continueSetup != true || !mounted) return;
    await Permission.location.request();
    await Permission.camera.request();
    await Permission.notification.request();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: index, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          indicatorColor: green.withValues(alpha: .14),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
            NavigationDestination(icon: Icon(Icons.route_outlined), selectedIcon: Icon(Icons.route), label: 'Viagens'),
            NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Carteira'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      );
}

class PassengerHome extends StatefulWidget {
  const PassengerHome({super.key});
  @override
  State<PassengerHome> createState() => _PassengerHomeState();
}

class _PassengerHomeState extends State<PassengerHome> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  @override
  Widget build(BuildContext context) => Column(children: [
        const PassengerHeader(),
        Expanded(
          child: Stack(
            children: [
              Container(color: const Color(0xFFE2E5E4), child: const Center(child: Text('Mapa', style: TextStyle(color: Colors.black38, fontSize: 18)))),
              DraggableScrollableSheet(
                initialChildSize: .45,
                minChildSize: .36,
                maxChildSize: .94,
                snap: true,
                snapSizes: const [.36, .94],
                builder: (context, controller) => Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(26)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -3))]),
                    child: ListView(
                      controller: controller,
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
                      children: [
                      Center(child: Container(width: 42, height: 5, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(5)))),
                      const SizedBox(height: 18),
                      const Text('Olá, Raul', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700, color: darkGreen)),
                      const SizedBox(height: 5),
                      const Text('Pra onde iremos?', style: TextStyle(fontSize: 17, color: Colors.black54)),
                      const SizedBox(height: 18),
                      const PassengerCard(icon: Icons.search, text: 'Digite seu destino'),
                        const SizedBox(height: 24),
                        const Text('Locais salvos', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        const PassengerListTile(icon: Icons.home_outlined, title: 'Casa', subtitle: 'Rua das Flores, 123'),
                        const PassengerListTile(icon: Icons.work_outline, title: 'Trabalho', subtitle: 'Av. Paulista, 1000'),
                        const PassengerListTile(icon: Icons.family_restroom_outlined, title: 'Casa da família', subtitle: 'Rua das Palmeiras, 45'),
                        const PassengerListTile(icon: Icons.school_outlined, title: 'Faculdade', subtitle: 'Av. Universitária, 800'),
                        const PassengerListTile(icon: Icons.local_grocery_store_outlined, title: 'Supermercado', subtitle: 'Rua do Comércio, 210'),
                        const PassengerListTile(icon: Icons.fitness_center_outlined, title: 'Academia', subtitle: 'Av. Central, 1500'),
                      ],
                    ),
                ),
              ),
            ],
          ),
        ),
      ]);
}

class PassengerTrips extends StatelessWidget {
  const PassengerTrips({super.key});
  @override
  Widget build(BuildContext context) => const PassengerPageFrame(
        title: 'Minhas viagens',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Viagens recentes', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
          SizedBox(height: 14),
          TripCard(date: 'Ter, 21 de jan de 2025', from: 'Casa', to: 'Shopping Ibirapuera'),
          TripCard(date: 'Seg, 20 de jan de 2025', from: 'Trabalho', to: 'Aeroporto de Congonhas'),
          TripCard(date: 'Sex, 17 de jan de 2025', from: 'Av. Faria Lima, 2231', to: 'Casa'),
          TripCard(date: 'Qui, 16 de jan de 2025', from: 'Casa', to: 'Parque Ibirapuera'),
          TripCard(date: 'Qua, 15 de jan de 2025', from: 'Shopping Morumbi', to: 'Trabalho'),
          TripCard(date: 'Ter, 14 de jan de 2025', from: 'Faculdade', to: 'Casa'),
          TripCard(date: 'Seg, 13 de jan de 2025', from: 'Aeroporto de Congonhas', to: 'Hotel Central'),
          TripCard(date: 'Dom, 12 de jan de 2025', from: 'Casa', to: 'Restaurante Paulista'),
        ]),
      );
}

class PassengerWallet extends StatelessWidget {
  const PassengerWallet({super.key});
  @override
  Widget build(BuildContext context) => const PassengerPageFrame(
        title: 'Carteira',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          BalanceCard(),
          SizedBox(height: 16),
          PassengerListTile(icon: Icons.credit_card, title: 'Forma de pagamento', subtitle: 'Cartão •••• 4567'),
          SizedBox(height: 14),
          Text('Últimas transações', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
          SizedBox(height: 10),
          PassengerListTile(icon: Icons.directions_car_outlined, title: 'Viagem', subtitle: '21 de jan • 09:14   - R\$ 18,90'),
          PassengerListTile(icon: Icons.add_circle_outline, title: 'Recarga de saldo', subtitle: '20 de jan • 18:20   + R\$ 100,00'),
          PassengerListTile(icon: Icons.directions_car_outlined, title: 'Viagem', subtitle: '19 de jan • 10:42   - R\$ 24,50'),
          PassengerListTile(icon: Icons.add_circle_outline, title: 'Recarga de saldo', subtitle: '18 de jan • 08:15   + R\$ 50,00'),
          PassengerListTile(icon: Icons.directions_car_outlined, title: 'Viagem', subtitle: '17 de jan • 19:30   - R\$ 16,80'),
          PassengerListTile(icon: Icons.directions_car_outlined, title: 'Viagem', subtitle: '16 de jan • 07:55   - R\$ 12,90'),
        ]),
      );
}

class PassengerProfile extends StatelessWidget {
  const PassengerProfile({super.key});
  @override
  Widget build(BuildContext context) => PassengerPageFrame(
        title: 'Meu perfil',
        child: Column(children: [
          const CircleAvatar(radius: 38, backgroundColor: Color(0xFFD9F5E3), child: Icon(Icons.person, size: 42, color: darkGreen)),
          const SizedBox(height: 10),
          const Text('Passageiro eMove', style: TextStyle(fontSize: 18, color: Colors.black54)),
          const SizedBox(height: 22),
          PassengerListTile(
            icon: Icons.person_outline,
            title: 'Dados pessoais',
            subtitle: 'Nome, telefone e e-mail',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerPersonalData())),
          ),
          PassengerListTile(icon: Icons.shield_outlined, title: 'Segurança', subtitle: 'Senha e privacidade', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerSecurity()))),
          PassengerListTile(icon: Icons.help_outline, title: 'Ajuda', subtitle: 'Fale com o suporte', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerHelp()))),
          PassengerListTile(icon: Icons.settings_outlined, title: 'Configurações', subtitle: 'Preferências do app', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerSettings()))),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const SplashScreen()), (_) => false),
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text('Sair', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
          ),
        ]),
      );
}

class PassengerHelp extends StatelessWidget {
  const PassengerHelp({super.key});
  @override
  Widget build(BuildContext context) => PassengerSubpage(title: 'Ajuda', subtitle: 'Como podemos ajudar?', children: [
    const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search, color: green), hintText: 'Busque uma dúvida', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))))),
    const SizedBox(height: 14),
    SecurityTile(icon: Icons.help_outline, title: 'Central de ajuda', subtitle: 'Encontre respostas para suas dúvidas', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerHelpCenter()))),
    SecurityTile(icon: Icons.headset_mic_outlined, title: 'Falar com o suporte', subtitle: 'Converse com nossa equipe', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerSupport()))),
    SecurityTile(icon: Icons.directions_car_outlined, title: 'Viagens e corridas', subtitle: 'Ajuda com solicitações e viagens', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerTripsHelp()))),
    SecurityTile(icon: Icons.account_balance_wallet_outlined, title: 'Pagamentos', subtitle: 'Valores, carteira e cobranças', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerPaymentHelp()))),
    SecurityTile(icon: Icons.shield_outlined, title: 'Segurança da conta', subtitle: 'Acesse orientações de segurança', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerAccountSecurity()))),
    const Center(child: Padding(padding: EdgeInsets.only(top: 12), child: Text('Atendimento eMove\nEstamos aqui para ajudar.', textAlign: TextAlign.center, style: TextStyle(color: darkGreen, fontSize: 16)))),
  ]);
}

class PassengerSupport extends StatefulWidget { const PassengerSupport({super.key}); @override State<PassengerSupport> createState() => _PassengerSupportState(); }
class _PassengerSupportState extends State<PassengerSupport> {
  String? subject;
  final message = TextEditingController();
  XFile? attachment;
  final picker = ImagePicker();
  final subjects = const ['Problema em uma viagem', 'Cancelamento de viagem', 'Motorista ou passageiro', 'Pagamento ou cobrança', 'Conta e perfil', 'Segurança', 'Aplicativo', 'Outros'];
  @override void dispose() { message.dispose(); super.dispose(); }
  void send() { if (subject == null || message.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione um assunto e escreva uma mensagem'))); return; } showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Solicitação enviada'), content: const Text('Recebemos sua mensagem. Nossa equipe responderá assim que possível.'), actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar'))])); }
  Future<void> pickAttachment() async { final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85); if (file != null && mounted) setState(() => attachment = file); }
  @override Widget build(BuildContext context) => PassengerSubpage(title: 'Falar com o suporte', subtitle: 'Conte o que aconteceu e nossa equipe ajudará você.', children: [DropdownButtonFormField<String>(value: subject, decoration: const InputDecoration(labelText: 'Assunto', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)))), items: [for (final item in subjects) DropdownMenuItem(value: item, child: Text(item))], onChanged: (value) => setState(() => subject = value)), const SizedBox(height: 14), TextField(controller: message, maxLines: 7, decoration: const InputDecoration(labelText: 'Mensagem', hintText: 'Escreva sua mensagem', alignLabelWithHint: true, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)))),), const SizedBox(height: 14), OutlinedButton(onPressed: pickAttachment, style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52), foregroundColor: darkGreen), child: Align(alignment: Alignment.centerLeft, child: Text(attachment == null ? 'Anexar arquivo' : 'Anexo: ${attachment!.name}'))), const Padding(padding: EdgeInsets.only(left: 4, top: 6), child: Align(alignment: Alignment.centerLeft, child: Text('Formatos aceitos: JPG, PNG ou PDF', style: TextStyle(color: Colors.black54, fontSize: 13)))), if (attachment != null) Padding(padding: const EdgeInsets.only(top: 10), child: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(attachment!.path), width: 62, height: 62, fit: BoxFit.cover)), const SizedBox(width: 10), Expanded(child: Text(attachment!.name, overflow: TextOverflow.ellipsis)), IconButton(onPressed: () => setState(() => attachment = null), icon: const Icon(Icons.close, color: Colors.redAccent))])), const SizedBox(height: 16), SecurityButton(label: 'Enviar mensagem', onPressed: send)]);
}

class PassengerTripsHelp extends StatelessWidget {
  const PassengerTripsHelp({super.key});
  @override
  Widget build(BuildContext context) => PassengerSubpage(title: 'Viagens e corridas', subtitle: 'Encontre respostas sobre suas viagens', children: [
    _HelpFlowTile(icon: Icons.alt_route_outlined, title: 'Solicitar uma viagem', subtitle: 'Como pedir e acompanhar uma viagem', onTap: () => _openHelpFlow(context, 'Solicitar uma viagem', 'Como solicitar uma viagem', const [
      ['Como informar o destino?', 'Digite o endereço de destino na tela inicial e escolha uma das sugestões apresentadas.'],
      ['Como confirmar o local de embarque?', 'Confira o ponto de embarque no mapa e ajuste o endereço antes de confirmar a solicitação.'],
      ['Como acompanhar a busca por motorista?', 'Depois de solicitar, acompanhe o status da busca na tela da viagem.'],
      ['Como cancelar uma solicitação?', 'Abra os detalhes da viagem e toque em Cancelar viagem.'],
      ['O que fazer se não encontrar motorista?', 'Aguarde alguns instantes, confira o local de embarque ou tente solicitar novamente.'],
    ])),
    _HelpFlowTile(icon: Icons.directions_car_outlined, title: 'Durante a viagem', subtitle: 'Informações sobre o trajeto e a corrida', onTap: () => _openHelpFlow(context, 'Durante a viagem', 'Acompanhe sua viagem com segurança', const [
      ['Como acompanhar o trajeto?', 'Acompanhe o deslocamento e o destino pelos detalhes da viagem.'],
      ['Como confirmar se estou no veículo certo?', 'Confira o nome do motorista, modelo, cor e placa antes de embarcar.'],
      ['Como compartilhar minha viagem?', 'Use a opção de compartilhar viagem para enviar os dados do trajeto a uma pessoa de confiança.'],
      ['O que fazer em caso de emergência?', 'Em uma emergência, procure um local seguro e acione os serviços de emergência. Depois, fale com o suporte.'],
      ['Como entrar em contato com o motorista?', 'Use o botão de contato disponível nos detalhes da viagem ativa.'],
    ])),
    _HelpFlowTile(icon: Icons.cancel_outlined, title: 'Cancelar uma viagem', subtitle: 'Veja quando e como cancelar', onTap: () => _openHelpFlow(context, 'Cancelar uma viagem', 'Saiba como cancelar sua viagem', const [
      ['Como cancelar antes do motorista chegar?', 'Abra a viagem ativa, toque em Cancelar viagem e confirme a ação.'],
      ['Existe taxa de cancelamento?', 'Quando aplicável, a informação da taxa será mostrada antes da confirmação.'],
      ['Como informar o motivo do cancelamento?', 'Selecione o motivo apresentado após tocar em Cancelar viagem.'],
      ['O que fazer se a viagem foi cancelada pelo motorista?', 'Você poderá solicitar outra viagem ou falar com o suporte.'],
      ['Como contestar uma cobrança de cancelamento?', 'Abra o suporte e envie os detalhes da cobrança para análise.'],
    ])),
    _HelpFlowTile(icon: Icons.warning_amber_outlined, title: 'Problemas na viagem', subtitle: 'Relate um problema ou ocorrência', onTap: () => _openHelpFlow(context, 'Problemas na viagem', 'Encontre ajuda para resolver sua viagem', const [
      ['O motorista não apareceu', 'Confira o ponto de embarque e tente entrar em contato. Se não resolver, relate o problema ao suporte.'],
      ['O motorista tomou um caminho diferente', 'Registre a ocorrência nos detalhes da viagem e informe o suporte.'],
      ['Esqueci um objeto no veículo', 'Abra o suporte, escolha a viagem e descreva o objeto esquecido.'],
      ['Tive um problema durante a viagem', 'Procure um local seguro e relate o ocorrido pelo suporte.'],
      ['Quero denunciar uma situação', 'Use o suporte para enviar os detalhes da situação e, se possível, anexar arquivos.'],
      ['Preciso de ajuda com outra situação', 'Escolha esta opção para falar com a equipe e explicar o que aconteceu.'],
    ])),
    _HelpFlowTile(icon: Icons.history_outlined, title: 'Histórico de viagens', subtitle: 'Tire dúvidas sobre suas viagens anteriores', onTap: () => _openHelpFlow(context, 'Histórico de viagens', 'Tire suas dúvidas sobre suas viagens anteriores', const [
      ['Onde encontro minhas viagens anteriores?', 'As viagens concluídas ficam disponíveis na aba Viagens, no histórico.'],
      ['Como vejo os detalhes de uma viagem?', 'Toque na viagem desejada para consultar seus detalhes.'],
      ['Como consultar o valor cobrado?', 'O valor aparece nos detalhes da viagem e também no histórico da Carteira.'],
      ['Por quanto tempo o histórico fica disponível?', 'O histórico permanece disponível enquanto a conta estiver ativa, conforme a política do aplicativo.'],
      ['O que fazer se uma viagem não aparecer?', 'Confira a conexão e tente novamente. Se continuar, entre em contato com o suporte.'],
      ['Como contestar uma cobrança?', 'Abra a viagem ou a transação e envie uma solicitação pelo suporte.'],
    ])),
  ]);

  static void _openHelpFlow(BuildContext context, String title, String subtitle, List<List<String>> questions) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PassengerHelpFlowPage(title: title, subtitle: subtitle, questions: questions)));
  }
}

class PassengerHelpFlowPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<List<String>> questions;
  const PassengerHelpFlowPage({super.key, required this.title, required this.subtitle, required this.questions});
  @override
  Widget build(BuildContext context) => PassengerSubpage(title: title, subtitle: subtitle, children: [
    for (final item in questions) _HelpQuestionCard(question: item[0], answer: item[1]),
  ]);
}

class _HelpQuestionCard extends StatelessWidget {
  final String question;
  final String answer;
  const _HelpQuestionCard({required this.question, required this.answer});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 0,
    shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.black12), borderRadius: BorderRadius.circular(14)),
    child: ExpansionTile(title: Text(question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16), children: [Align(alignment: Alignment.centerLeft, child: Text(answer, style: const TextStyle(color: Colors.black54, fontSize: 15)))]),
  );
}

class PassengerAccountSecurity extends StatelessWidget {
  const PassengerAccountSecurity({super.key});
  @override
  Widget build(BuildContext context) => PassengerSubpage(title: 'Segurança da conta', subtitle: 'Proteja sua conta e seus dados', children: [
    _HelpFlowTile(icon: Icons.lock_outline, title: 'Senha', subtitle: 'Altere ou recupere sua senha', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerPassword()))),
    _HelpFlowTile(icon: Icons.verified_user_outlined, title: 'Verificação em duas etapas', subtitle: 'Adicione uma camada extra de proteção', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerSubpage(title: 'Verificação em duas etapas', subtitle: 'Adicione uma camada extra de proteção', children: [])))),
    _HelpFlowTile(icon: Icons.devices_outlined, title: 'Dispositivos conectados', subtitle: 'Veja onde sua conta está conectada', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerSubpage(title: 'Dispositivos conectados', subtitle: 'Veja onde sua conta está conectada', children: [])))),
    _HelpFlowTile(icon: Icons.warning_amber_outlined, title: 'Atividade suspeita', subtitle: 'Saiba o que fazer em caso de acesso não reconhecido', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerSubpage(title: 'Atividade suspeita', subtitle: 'Se você não reconhece um acesso, altere sua senha e fale com o suporte.', children: [])))),
  ]);
}

class _HelpFlowTile extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
  const _HelpFlowTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 12), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15), decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(14)), child: Row(children: [Icon(icon, color: green, size: 25), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 15))])), const Icon(Icons.chevron_right, color: Colors.black45)]))));
}

class PassengerHelpCenter extends StatelessWidget {
  const PassengerHelpCenter({super.key});
  @override
  Widget build(BuildContext context) => PassengerSubpage(title: 'Central de ajuda', subtitle: 'Encontre respostas para suas dúvidas', children: [
    const TextField(decoration: InputDecoration(hintText: 'Busque uma dúvida', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))))),
    const SizedBox(height: 18),
    const Text('Perguntas frequentes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: darkGreen)),
    HelpQuestion(question: 'Como solicitar uma viagem?', answer: 'Informe o destino na tela inicial, confira a estimativa e toque em Solicitar viagem.'),
    HelpQuestion(question: 'Como cancelar uma viagem?', answer: 'Abra os detalhes da viagem ativa e toque em Cancelar viagem. As condições podem variar conforme o andamento da corrida.'),
    HelpQuestion(question: 'Como acompanhar o motorista?', answer: 'Depois da confirmação, acompanhe a localização e o status do motorista pelo mapa da viagem.'),
    HelpQuestion(question: 'Como funciona o pagamento?', answer: 'O pagamento é processado pela forma escolhida na Carteira e o histórico fica disponível após a viagem.'),
    const SizedBox(height: 16),
    const Text('Categorias', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: darkGreen)),
    HelpCategory(title: 'Viagens e corridas', questions: const ['Como solicitar uma viagem?', 'Como cancelar uma viagem?', 'Como acompanhar o motorista?', 'O que fazer se o motorista não aparecer?']),
    HelpCategory(title: 'Pagamentos', questions: const ['Quais formas de pagamento são aceitas?', 'Como adicionar um cartão?', 'Como consultar uma cobrança?', 'Como solicitar reembolso?']),
    HelpCategory(title: 'Conta e perfil', questions: const ['Como editar meus dados?', 'Como trocar a senha?', 'Como alterar telefone ou e-mail?', 'Como excluir a conta?']),
    HelpCategory(title: 'Segurança', questions: const ['Como proteger minha conta?', 'Como funciona a verificação em duas etapas?', 'O que fazer se eu perder o celular?', 'Como denunciar uma situação?']),
  ]);
}

class PassengerPaymentHelp extends StatelessWidget {
  const PassengerPaymentHelp({super.key});
  @override
  Widget build(BuildContext context) => PassengerSubpage(title: 'Pagamentos', subtitle: 'Encontre respostas sobre pagamentos e cobranças', children: [
    const _HelpQuestionCard(question: 'Como adicionar uma forma de pagamento?', answer: 'Acesse a Carteira, escolha Forma de pagamento e siga as instruções para adicionar um cartão ou outra opção disponível.'),
    const _HelpQuestionCard(question: 'Por que meu pagamento foi recusado?', answer: 'Confira os dados da forma de pagamento, o limite disponível e se o cartão está válido. Se o problema continuar, tente outra forma de pagamento.'),
    const _HelpQuestionCard(question: 'Como consultar uma cobrança?', answer: 'Abra o histórico da viagem ou a Carteira para consultar os detalhes e o valor cobrado.'),
    const _HelpQuestionCard(question: 'Como solicitar um reembolso?', answer: 'Abra os detalhes da viagem, entre em contato com o suporte e informe o motivo da solicitação.'),
    const _HelpQuestionCard(question: 'O que fazer se fui cobrado duas vezes?', answer: 'Confira se uma das cobranças está apenas pendente. Se as duas forem confirmadas, envie os dados ao suporte para análise.'),
    const _HelpQuestionCard(question: 'Como obter o comprovante da viagem?', answer: 'Abra os detalhes da viagem concluída e procure a opção de comprovante.'),
    const _HelpQuestionCard(question: 'Outra dúvida sobre pagamento?', answer: 'Fale com o suporte pelo formulário de atendimento e descreva o que aconteceu.'),
  ]);
}

class HelpQuestion extends StatelessWidget { final String question; final String answer; const HelpQuestion({super.key, required this.question, required this.answer}); @override Widget build(BuildContext context) => ExpansionTile(title: Text(question, style: const TextStyle(fontSize: 16)), childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12), children: [Text(answer, style: const TextStyle(color: Colors.black54, fontSize: 15))]); }
class HelpCategory extends StatelessWidget { final String title; final List<String> questions; const HelpCategory({super.key, required this.title, required this.questions}); @override Widget build(BuildContext context) => ExpansionTile(title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), children: [for (final question in questions) ListTile(dense: true, title: Text(question), trailing: const Icon(Icons.chevron_right, color: Colors.black45), onTap: () {})]); }

class PassengerSettings extends StatelessWidget {
  const PassengerSettings({super.key});
  @override
  Widget build(BuildContext context) => PassengerSubpage(title: 'Configurações', subtitle: 'Personalize sua experiência no eMove', children: [
    SecurityTile(icon: Icons.tune, title: 'Preferências do app', subtitle: 'Escolha como o aplicativo funciona', onTap: () {}),
    SecurityTile(icon: Icons.translate, title: 'Idioma', subtitle: 'Português (Brasil)', onTap: () {}),
    SecurityTile(icon: Icons.light_mode_outlined, title: 'Aparência', subtitle: 'Tema claro', onTap: () {}),
    SecurityTile(icon: Icons.volume_up_outlined, title: 'Som e vibração', subtitle: 'Sons e alertas do aplicativo', onTap: () {}),
    SecurityTile(icon: Icons.info_outline, title: 'Sobre o eMove', subtitle: 'Versão, termos e informações do app', onTap: () {}),
    TextButton.icon(onPressed: () {}, icon: const Icon(Icons.refresh, color: green), label: const Text('Restaurar preferências', style: TextStyle(color: green, fontSize: 16))),
  ]);
}

class PassengerSecurity extends StatelessWidget {
  const PassengerSecurity({super.key});
  @override
  Widget build(BuildContext context) => PassengerSubpage(title: 'Segurança', subtitle: 'Proteja sua conta e controle sua privacidade', children: [
    SecurityTile(icon: Icons.lock_outline, title: 'Senha', subtitle: 'Altere sua senha de acesso', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerPassword()))),
    SecurityTile(icon: Icons.privacy_tip_outlined, title: 'Privacidade', subtitle: 'Controle seus dados e permissões', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerPrivacy()))),
    SecurityTile(icon: Icons.verified_user_outlined, title: 'Verificação em duas etapas', subtitle: 'Adicione uma camada extra de proteção', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerTwoStep()))),
    SecurityTile(icon: Icons.devices_outlined, title: 'Dispositivos conectados', subtitle: 'Gerencie os aparelhos com acesso à conta', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerDevices()))),
  ]);
}

class PassengerPassword extends StatefulWidget {
  const PassengerPassword({super.key});
  @override
  State<PassengerPassword> createState() => _PassengerPasswordState();
}

class _PassengerPasswordState extends State<PassengerPassword> {
  final current = TextEditingController();
  final next = TextEditingController();
  final confirmation = TextEditingController();
  String? currentError;
  String? nextError;
  String? confirmationError;

  @override
  void dispose() {
    current.dispose();
    next.dispose();
    confirmation.dispose();
    super.dispose();
  }

  void updatePassword() {
    setState(() {
      currentError = current.text.trim().isEmpty || current.text != '12345678' ? 'Senha atual incorreta' : null;
      nextError = next.text.length < 8 ? 'A nova senha deve ter pelo menos 8 caracteres' : null;
      confirmationError = confirmation.text != next.text || confirmation.text.isEmpty ? 'As senhas não coincidem' : null;
    });
    if (currentError != null || nextError != null || confirmationError != null) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha atualizada com sucesso')));
  }

  @override
  Widget build(BuildContext context) => PassengerSubpage(title: 'Senha', subtitle: 'Atualize sua senha de acesso', children: [
        SecurityInput(controller: current, label: 'Senha atual', errorText: currentError, onChanged: (_) { if (currentError != null) setState(() => currentError = null); }),
        SecurityInput(controller: next, label: 'Nova senha', errorText: nextError, onChanged: (_) { if (nextError != null) setState(() => nextError = null); }),
        SecurityInput(controller: confirmation, label: 'Confirmar nova senha', errorText: confirmationError, onChanged: (_) { if (confirmationError != null) setState(() => confirmationError = null); }),
        const Text('Use pelo menos 8 caracteres, com letras e números.', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 16),
        SecurityButton(label: 'Atualizar senha', onPressed: updatePassword),
      ]);
}
class PassengerPrivacy extends StatelessWidget {
  const PassengerPrivacy({super.key});
  @override
  Widget build(BuildContext context) => PassengerSubpage(
        title: 'Privacidade',
        subtitle: 'Gerencie como seus dados são usados no app',
        children: [
          SecurityTile(icon: Icons.tune, title: 'Permissões do aplicativo', subtitle: 'Localização, câmera e notificações', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerPermissions()))),
          SecurityTile(icon: Icons.location_on_outlined, title: 'Localização', subtitle: 'Usada para melhorar suas corridas', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerSettingPage(title: 'Localização', items: ['Permissão de localização', 'Localização precisa'])))),
          SecurityTile(icon: Icons.notifications_none, title: 'Notificações', subtitle: 'Alertas de viagens e segurança', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerSettingPage(title: 'Notificações', items: ['Permitir notificações', 'Alertas de viagens', 'Alertas de segurança', 'Ofertas e novidades'])))),
          SecurityTile(icon: Icons.storage_outlined, title: 'Dados e personalização', subtitle: 'Escolha como usamos seus dados', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerSettingPage(title: 'Dados e personalização', items: ['Histórico de viagens', 'Sugestões personalizadas', 'Dados de diagnóstico', 'Compartilhamento para melhorias'])))),
          SecurityTile(icon: Icons.description_outlined, title: 'Política de privacidade', subtitle: 'Leia como protegemos suas informações', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PassengerSettingPage(title: 'Política de privacidade', items: ['Resumo', 'Quais dados coletamos', 'Como usamos seus dados', 'Seus direitos'])))),
        ],
      );
}
class PassengerTwoStep extends StatelessWidget { const PassengerTwoStep({super.key}); @override Widget build(BuildContext context) => PassengerSettingPage(title: 'Verificação em duas etapas', items: const ['Ativar verificação em duas etapas', 'Código por SMS', 'Código por e-mail']); }
class PassengerDevices extends StatelessWidget { const PassengerDevices({super.key}); @override Widget build(BuildContext context) => PassengerSettingPage(title: 'Dispositivos conectados', items: const ['Sua conta está segura', 'Samsung Galaxy — Este dispositivo', 'Nenhum outro dispositivo conectado']); }
class PassengerPermissions extends StatefulWidget { const PassengerPermissions({super.key}); @override State<PassengerPermissions> createState() => _PassengerPermissionsState(); }
class _PassengerPermissionsState extends State<PassengerPermissions> {
  Map<Permission, PermissionStatus> statuses = {};
  @override void initState() { super.initState(); _refresh(); }
  Future<void> _refresh() async { final values = await Future.wait([Permission.location.status, Permission.camera.status, Permission.notification.status]); if (mounted) setState(() => statuses = {Permission.location: values[0], Permission.camera: values[1], Permission.notification: values[2]}); }
  String _label(Permission permission) { final status = statuses[permission]; if (status == null || status!.isDenied) return 'Não permitida'; if (status.isPermanentlyDenied) return 'Bloqueada'; return 'Permitida'; }
  Future<void> _request(Permission permission) async { final status = await permission.request(); if (status.isPermanentlyDenied) { await AppSettings.openAppSettings(); } await _refresh(); }
  @override Widget build(BuildContext context) => PassengerSubpage(title: 'Permissões do aplicativo', subtitle: 'Gerencie o acesso do eMove aos recursos do aparelho', children: [SecurityTile(icon: Icons.location_on_outlined, title: 'Localização', subtitle: _label(Permission.location), onTap: () => _request(Permission.location)), SecurityTile(icon: Icons.camera_alt_outlined, title: 'Câmera', subtitle: _label(Permission.camera), onTap: () => _request(Permission.camera)), SecurityTile(icon: Icons.notifications_none, title: 'Notificações', subtitle: _label(Permission.notification), onTap: () => _request(Permission.notification)), const Text('Se uma permissão estiver bloqueada, o Android abrirá as configurações do eMove.', style: TextStyle(color: Colors.black54))]);
}
class PassengerSettingPage extends StatelessWidget { final String title; final List<String> items; const PassengerSettingPage({super.key, required this.title, required this.items}); @override Widget build(BuildContext context) => PassengerSubpage(title: title, subtitle: 'Gerencie suas preferências no eMove', children: [for (final item in items) SecurityTile(icon: Icons.settings_outlined, title: item, subtitle: 'Toque para alterar ou consultar', onTap: () {})]); }

class PassengerSubpage extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  const PassengerSubpage({super.key, required this.title, required this.subtitle, required this.children});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: Column(children: [
          const PassengerHeader(),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(22, 8, 22, 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back, color: darkGreen)), Expanded(child: Text(title, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700, color: darkGreen)))]),
            Text(subtitle, style: const TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 18),
            ...children,
          ]))),
        ])),
        bottomNavigationBar: NavigationBar(selectedIndex: 3, onDestinationSelected: (value) => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => PassengerShell(initialIndex: value)), (_) => false), destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Início'), NavigationDestination(icon: Icon(Icons.route_outlined), label: 'Viagens'), NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Carteira'), NavigationDestination(icon: Icon(Icons.person), label: 'Perfil')]),
      );
}
class SecurityTile extends StatelessWidget { final IconData icon; final String title; final String subtitle; final VoidCallback onTap; const SecurityTile({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap}); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(14)), child: Row(children: [Icon(icon, color: green, size: 28), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), Text(subtitle, style: const TextStyle(color: Colors.black54))])), const Icon(Icons.chevron_right, color: Colors.black45)])))); }
class SecurityInput extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  const SecurityInput({super.key, required this.label, this.controller, this.errorText, this.onChanged});
  @override
  State<SecurityInput> createState() => _SecurityInputState();
}

class _SecurityInputState extends State<SecurityInput> {
  bool hidden = true;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          obscureText: hidden,
          decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: const Icon(Icons.lock_outline, color: green),
            suffixIcon: IconButton(
              tooltip: hidden ? 'Mostrar senha' : 'Ocultar senha',
              onPressed: () => setState(() => hidden = !hidden),
              icon: Icon(hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            ),
            errorText: widget.errorText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
}

class SecurityButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const SecurityButton({super.key, required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: darkGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)), onPressed: onPressed, child: Text(label)));
}

class PassengerPersonalData extends StatefulWidget {
  const PassengerPersonalData({super.key});

  @override
  State<PassengerPersonalData> createState() => _PassengerPersonalDataState();
}

class _PassengerPersonalDataState extends State<PassengerPersonalData> {
  final Map<String, String> _data = {
    'Nome completo': '',
    'Telefone': '',
    'E-mail': '',
    'CPF': '',
    'Data de nascimento': '',
    'Endereço': '',
  };

  Future<void> _editField(String title) async {
    final controller = TextEditingController(text: _data[title]);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(labelText: title, border: const OutlineInputBorder()),
          onSubmitted: (_) => Navigator.of(context).pop(controller.text.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(context).pop(controller.text.trim()), child: const Text('Salvar')),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result.isNotEmpty) setState(() => _data[title] = result);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          color: Colors.white,
          child: Material(
          color: Colors.white,
          child: Column(children: [
            const PassengerHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                IconButton(
                  tooltip: 'Voltar',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: darkGreen, size: 28),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 10),
                const Text('Dados pessoais', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: darkGreen, decoration: TextDecoration.none)),
              ]),
              const SizedBox(height: 18),
              PersonalDataTile(icon: Icons.person_outline, title: 'Nome completo', value: _data['Nome completo']!, onSaved: (value) => setState(() => _data['Nome completo'] = value)),
              PersonalDataTile(icon: Icons.phone_outlined, title: 'Telefone', value: _data['Telefone']!, onSaved: (value) => setState(() => _data['Telefone'] = value)),
              PersonalDataTile(icon: Icons.mail_outline, title: 'E-mail', value: _data['E-mail']!, onSaved: (value) => setState(() => _data['E-mail'] = value)),
              PersonalDataTile(icon: Icons.badge_outlined, title: 'CPF', value: _data['CPF']!, onSaved: (value) => setState(() => _data['CPF'] = value)),
              PersonalDataTile(icon: Icons.calendar_month_outlined, title: 'Data de nascimento', value: _data['Data de nascimento']!, onSaved: (value) => setState(() => _data['Data de nascimento'] = value)),
              PersonalDataTile(icon: Icons.location_on_outlined, title: 'Endereço', value: _data['Endereço']!, onSaved: (value) => setState(() => _data['Endereço'] = value)),
                ]),
              ),
            ),
          ]),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: 3,
          onDestinationSelected: (value) => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => PassengerShell(initialIndex: value)), (_) => false),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Início'),
            NavigationDestination(icon: Icon(Icons.route_outlined), label: 'Viagens'),
            NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Carteira'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      );
}

class PassengerPageFrame extends StatelessWidget {
  final String title;
  final Widget child;
  const PassengerPageFrame({super.key, required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Column(children: [
        const PassengerHeader(),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(22, 18, 22, 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: darkGreen)),
          const SizedBox(height: 18),
          child,
        ]))),
      ]);
}

class PassengerHeader extends StatelessWidget {
  const PassengerHeader({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(bottom: false, child: Container(height: 72, color: Colors.white, alignment: Alignment.center, child: SizedBox(width: 180, height: 42, child: Image.asset('assets/logo_oficial_transparente.png', fit: BoxFit.contain))));
}

class PassengerCard extends StatelessWidget {
  final IconData icon; final String text;
  const PassengerCard({super.key, required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFFF2F5F3), borderRadius: BorderRadius.circular(18)), child: Row(children: [Icon(icon, color: darkGreen), const SizedBox(width: 12), Text(text, style: const TextStyle(fontSize: 17, color: Colors.black54))]));
}

class PassengerListTile extends StatelessWidget {
  final IconData icon; final String title; final String subtitle;
  final VoidCallback? onTap;
  const PassengerListTile({super.key, required this.icon, required this.title, required this.subtitle, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14), decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(icon, color: green), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black54))])), const Icon(Icons.chevron_right, color: Colors.black45)])),
      );
}

class PersonalDataTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final ValueChanged<String> onSaved;
  const PersonalDataTile({super.key, required this.icon, required this.title, required this.value, required this.onSaved});
  @override
  State<PersonalDataTile> createState() => _PersonalDataTileState();
}

class _PersonalDataTileState extends State<PersonalDataTile> {
  late final TextEditingController controller = TextEditingController(text: widget.value);
  @override
  void dispose() { controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Icon(widget.icon, color: green, size: 25),
          const SizedBox(width: 12),
          Expanded(child: TextField(
            controller: controller,
            keyboardType: _keyboardType,
            inputFormatters: _formatters,
            onChanged: widget.onSaved,
            style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              labelText: widget.title,
              labelStyle: const TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w400),
              floatingLabelStyle: const TextStyle(fontSize: 15, color: darkGreen, fontWeight: FontWeight.w400),
              hintText: _hint,
              errorText: _error,
              suffixIcon: _isValid ? const Icon(Icons.check_circle, color: green) : null,
              isDense: true,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
          )),
        ]),
      );

  TextInputType get _keyboardType { if (widget.title == 'E-mail') return TextInputType.emailAddress; if (widget.title == 'Telefone' || widget.title == 'CPF' || widget.title == 'Data de nascimento') return TextInputType.number; return TextInputType.text; }
  List<TextInputFormatter> get _formatters { if (widget.title == 'Telefone') return [DigitsMaskFormatter(mask: '(##) #####-####')]; if (widget.title == 'CPF') return [DigitsMaskFormatter(mask: '###.###.###-##')]; if (widget.title == 'Data de nascimento') return [DigitsMaskFormatter(mask: '##/##/####')]; return const []; }
  String? get _hint { if (widget.title == 'Telefone') return '(00) 00000-0000'; if (widget.title == 'CPF') return '000.000.000-00'; if (widget.title == 'Data de nascimento') return 'DD/MM/AAAA'; return null; }
  bool get _isValid { final value = controller.text.trim(); if (value.isEmpty) return false; if (widget.title == 'Telefone' || widget.title == 'CPF') return value.replaceAll(RegExp(r'\D'), '').length == 11; if (widget.title == 'E-mail') return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value); if (widget.title == 'Data de nascimento') { final parts = value.split('/'); if (parts.length != 3) return false; final day = int.tryParse(parts[0]); final month = int.tryParse(parts[1]); final year = int.tryParse(parts[2]); if (day == null || month == null || year == null) return false; final date = DateTime(year, month, day); return date.year == year && date.month == month && date.day == day; } return value.length >= 2; }
  String? get _error { if (controller.text.isEmpty || _isValid) return null; if (widget.title == 'Telefone') return 'Digite um telefone válido'; if (widget.title == 'CPF') return 'Digite um CPF válido'; if (widget.title == 'E-mail') return 'Digite um e-mail válido'; if (widget.title == 'Data de nascimento') return 'Digite uma data válida'; return 'Preencha este campo'; }
}

class DigitsMaskFormatter extends TextInputFormatter {
  final String mask;
  DigitsMaskFormatter({required this.mask});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    var index = 0;
    for (final char in mask.split('')) {
      if (char == '#') {
        if (index >= digits.length) break;
        buffer.write(digits[index++]);
      } else {
        if (index < digits.length) buffer.write(char);
      }
    }
    final text = buffer.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

class TripCard extends StatelessWidget {
  final String date; final String from; final String to;
  const TripCard({super.key, required this.date, required this.from, required this.to});
  @override
  Widget build(BuildContext context) => PassengerListTile(icon: Icons.directions_car_outlined, title: '$from → $to', subtitle: '$date   •   Concluída');
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: darkGreen, borderRadius: BorderRadius.circular(18)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Saldo eMove', style: TextStyle(color: Colors.white70, fontSize: 16)), SizedBox(height: 7), Text('R\$ 50,00', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700))]));
}

class EmoveLogo extends StatelessWidget {
  final double width;
  final double height;
  const EmoveLogo({super.key, this.width = 270, this.height = 60});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: Image.asset('assets/logo_oficial_transparente.png', fit: BoxFit.contain),
  );
}

class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
  );
}

class InputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final VoidCallback? onTap;
  const InputField({
    super.key,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => TextField(
    onTap: onTap,
    obscureText: obscureText,
    style: const TextStyle(fontSize: 16),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 16),
      prefixIcon: Icon(icon, size: 24, color: Colors.black87),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: Colors.black45, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: green, width: 2),
      ),
    ),
  );
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(child: Divider(thickness: 1.2)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Text(
          'OU',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
      Expanded(child: Divider(thickness: 1.2)),
    ],
  );
}
