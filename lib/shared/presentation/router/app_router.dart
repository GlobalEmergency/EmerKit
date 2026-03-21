import 'package:go_router/go_router.dart';
import 'package:navaja_suiza_sanitaria/features/splash/presentation/splash_screen.dart';
import 'package:navaja_suiza_sanitaria/features/home/presentation/home_screen.dart';
import 'package:navaja_suiza_sanitaria/features/about/presentation/about_screen.dart';
import 'package:navaja_suiza_sanitaria/features/feedback/presentation/feedback_screen.dart';
import 'package:navaja_suiza_sanitaria/features/glasgow/presentation/glasgow_screen.dart';
import 'package:navaja_suiza_sanitaria/features/vital_signs/presentation/vital_signs_screen.dart';
import 'package:navaja_suiza_sanitaria/features/glucemia/presentation/glucemia_screen.dart';
import 'package:navaja_suiza_sanitaria/features/triage/presentation/triage_screen.dart';
import 'package:navaja_suiza_sanitaria/features/tep/presentation/tep_screen.dart';
import 'package:navaja_suiza_sanitaria/features/heart_rate/presentation/heart_rate_screen.dart';
import 'package:navaja_suiza_sanitaria/features/o2_calculator/presentation/o2_calculator_screen.dart';
import 'package:navaja_suiza_sanitaria/features/oxigenoterapia/presentation/oxigenoterapia_screen.dart';
import 'package:navaja_suiza_sanitaria/features/ecg/presentation/ecg_leads_screen.dart';
import 'package:navaja_suiza_sanitaria/features/lund_browder/presentation/lund_browder_screen.dart';
import 'package:navaja_suiza_sanitaria/features/rcp/presentation/rcp_rithm_screen.dart';
import 'package:navaja_suiza_sanitaria/features/rcp/presentation/plan_rcp_screen.dart';
import 'package:navaja_suiza_sanitaria/features/adr/presentation/adr_screen.dart';
import 'package:navaja_suiza_sanitaria/features/epi/presentation/epi_screen.dart';
import 'package:navaja_suiza_sanitaria/features/vendajes/presentation/vendajes_screen.dart';
import 'package:navaja_suiza_sanitaria/features/heridas/presentation/heridas_screen.dart';
import 'package:navaja_suiza_sanitaria/features/posiciones/presentation/posiciones_screen.dart';
import 'package:navaja_suiza_sanitaria/features/ictus/presentation/ictus_screen.dart';
import 'package:navaja_suiza_sanitaria/features/hipotermia/presentation/hipotermia_screen.dart';
import 'package:navaja_suiza_sanitaria/features/hipertermia/presentation/hipertermia_screen.dart';
import 'package:navaja_suiza_sanitaria/features/comm/presentation/comm_screen.dart';
import 'package:navaja_suiza_sanitaria/features/nihss/presentation/nihss_screen.dart';
import 'package:navaja_suiza_sanitaria/features/rankin/presentation/rankin_screen.dart';

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
