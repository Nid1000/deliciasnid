import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  final List<_Msg> _messages = [
    _Msg.bot(
      '¡Hola! Soy el chatbot de Delicias del Centro 🍞🍰\n'
      'Pregúntame sobre: promociones, pedidos, delivery, pagos, horarios, dirección.',
    ),
  ];

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Msg.user(text));
      _messages.add(_Msg.bot(_reply(text)));
    });

    _controller.clear();
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _reply(String input) {
    final q = input.toLowerCase();

    if (q.contains('hola') || q.contains('buenas') || q.contains('hey')) {
      return '¡Hola! 😊 ¿En qué te ayudo hoy?';
    }

    if (q.contains('horario') || q.contains('abren') || q.contains('cierran')) {
      return 'Atendemos todos los días de 8:00 a.m. a 9:00 p.m. 🕘';
    }

    if (q.contains('delivery') ||
        q.contains('envío') ||
        q.contains('envio') ||
        q.contains('reparto')) {
      return 'Sí tenemos delivery 🚚. Puedes pedir desde “Mi pedido” y elegir dirección. '
          'El tiempo promedio es 30–45 min (según zona).';
    }

    if (q.contains('pago') ||
        q.contains('pagar') ||
        q.contains('yape') ||
        q.contains('tarjeta') ||
        q.contains('contra entrega')) {
      return 'Aceptamos pago contra entrega, Yape y tarjeta 💳📲. '
          'En “Proceso de pago” eliges el método.';
    }

    if (q.contains('promo') ||
        q.contains('promoción') ||
        q.contains('promocion') ||
        q.contains('oferta')) {
      return 'Las promociones están en la sección “Promociones” 🎉. '
          'También revisa “Nuevos productos” para combos.';
    }

    if (q.contains('pedido') ||
        q.contains('seguimiento') ||
        q.contains('estado')) {
      return 'Puedes ver el estado en “Seguimiento” 📦. '
          'Estados: Preparando → En camino → Entregado.';
    }

    if (q.contains('ubicación') ||
        q.contains('ubicacion') ||
        q.contains('dirección') ||
        q.contains('direccion') ||
        q.contains('donde')) {
      return 'Puedes guardar tu dirección en “Dirección” 📍. '
          'Si deseas, dime tu distrito y te indico cobertura de delivery.';
    }

    if (q.contains('contacto') ||
        q.contains('teléfono') ||
        q.contains('telefono') ||
        q.contains('soporte') ||
        q.contains('ayuda')) {
      return 'Soporte: soporte@delicias.com 📩\nTambién puedes escribir “Necesito ayuda con mi pedido”.';
    }

    return 'Entiendo 🤔. Puedo ayudarte con promociones, pedidos, delivery, pagos, horarios y dirección.\n'
        'Prueba preguntando: “¿Tienen delivery?”, “¿Cómo pago con Yape?”, “¿Cuál es el horario?”';
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Chatbot'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _Bubble(m: _messages[i]),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu pregunta...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _send, child: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isUser;
  const _Msg._(this.text, this.isUser);

  factory _Msg.user(String t) => _Msg._(t, true);
  factory _Msg.bot(String t) => _Msg._(t, false);
}

class _Bubble extends StatelessWidget {
  final _Msg m;
  const _Bubble({required this.m});

  @override
  Widget build(BuildContext context) {
    final align = m.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bg = m.isUser ? AppColors.accent2 : AppColors.card;
    final txt = m.isUser ? Colors.white : AppColors.text;

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          m.text,
          style: TextStyle(color: txt, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
