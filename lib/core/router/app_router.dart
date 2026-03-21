import 'package:go_router/go_router.dart';
import '../../screens/splash_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/about_screen.dart';
import '../../screens/feedback_screen.dart';
import '../../screens/glasgow_screen.dart';
import '../../screens/vital_signs_screen.dart';
import '../../screens/glucemia_screen.dart';
import '../../screens/triage_screen.dart';
import '../../screens/tep_screen.dart';
import '../../screens/heart_rate_screen.dart';
import '../../screens/o2_calculator_screen.dart';
import '../../screens/oxigenoterapia_screen.dart';
import '../../screens/ecg_leads_screen.dart';
import '../../screens/lund_browder_screen.dart';
import '../../screens/rcp_rithm_screen.dart';
import '../../screens/plan_rcp_screen.dart';
import '../../screens/adr_screen.dart';
import '../../screens/epi_screen.dart';
import '../../screens/vendajes_screen.dart';
import '../../screens/heridas_screen.dart';
import '../../screens/posiciones_screen.dart';
import '../../screens/ictus_screen.dart';
import '../../screens/hipotermia_screen.dart';
import '../../screens/hipertermia_screen.dart';
import '../../screens/comm_screen.dart';
import '../../screens/nihss_screen.dart';
import '../../screens/rankin_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/about', builder: (_, __) => const AboutScreen()),
    GoRoute(path: '/feedback', builder: (_, __) => const FeedbackScreen()),
    GoRoute(path: '/glasgow', builder: (_, __) => const GlasgowScreen()),
    GoRoute(path: '/vital-signs', builder: (_, __) => const VitalSignsScreen()),
    GoRoute(path: '/glucemia', builder: (_, __) => const GlucemiaScreen()),
    GoRoute(path: '/triage', builder: (_, __) => const TriageScreen()),
    GoRoute(path: '/tep', builder: (_, __) => const TepScreen()),
    GoRoute(path: '/heart-rate', builder: (_, __) => const HeartRateScreen()),
    GoRoute(path: '/o2-calculator', builder: (_, __) => const O2CalculatorScreen()),
    GoRoute(path: '/oxigenoterapia', builder: (_, __) => const OxigenoterapiaScreen()),
    GoRoute(path: '/ecg-leads', builder: (_, __) => const EcgLeadsScreen()),
    GoRoute(path: '/lund-browder', builder: (_, __) => const LundBrowderScreen()),
    GoRoute(path: '/rcp-rithm', builder: (_, __) => const RcpRithmScreen()),
    GoRoute(path: '/plan-rcp', builder: (_, __) => const PlanRcpScreen()),
    GoRoute(path: '/adr', builder: (_, __) => const AdrScreen()),
    GoRoute(path: '/epi', builder: (_, __) => const EpiScreen()),
    GoRoute(path: '/vendajes', builder: (_, __) => const VendajesScreen()),
    GoRoute(path: '/heridas', builder: (_, __) => const HeridasScreen()),
    GoRoute(path: '/posiciones', builder: (_, __) => const PosicionesScreen()),
    GoRoute(path: '/ictus', builder: (_, __) => const IctusScreen()),
    GoRoute(path: '/hipotermia', builder: (_, __) => const HipotermiaScreen()),
    GoRoute(path: '/hipertermia', builder: (_, __) => const HipertermiaScreen()),
    GoRoute(path: '/comm', builder: (_, __) => const CommScreen()),
    GoRoute(path: '/nihss', builder: (_, __) => const NihssScreen()),
    GoRoute(path: '/rankin', builder: (_, __) => const RankinScreen()),
  ],
);
