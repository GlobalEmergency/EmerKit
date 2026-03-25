import 'package:go_router/go_router.dart';
import 'package:emerkit/features/splash/presentation/splash_screen.dart';
import 'package:emerkit/features/home/presentation/home_screen.dart';
import 'package:emerkit/features/about/presentation/about_screen.dart';
import 'package:emerkit/features/feedback/presentation/feedback_screen.dart';
import 'package:emerkit/features/glasgow/presentation/glasgow_screen.dart';
import 'package:emerkit/features/vital_signs/presentation/vital_signs_screen.dart';
import 'package:emerkit/features/glucemia/presentation/glucemia_screen.dart';
import 'package:emerkit/features/triage/presentation/triage_screen.dart';
import 'package:emerkit/features/tep/presentation/tep_screen.dart';
import 'package:emerkit/features/heart_rate/presentation/heart_rate_screen.dart';
import 'package:emerkit/features/o2_calculator/presentation/o2_calculator_screen.dart';
import 'package:emerkit/features/oxigenoterapia/presentation/oxigenoterapia_screen.dart';
import 'package:emerkit/features/ecg/presentation/ecg_leads_screen.dart';
import 'package:emerkit/features/lund_browder/presentation/lund_browder_screen.dart';
import 'package:emerkit/features/rcp/presentation/rcp_screen.dart';
import 'package:emerkit/features/rcp/presentation/plan_rcp_screen.dart';
import 'package:emerkit/features/adr/presentation/adr_screen.dart';
import 'package:emerkit/features/epi/presentation/epi_screen.dart';
import 'package:emerkit/features/vendajes/presentation/vendajes_screen.dart';
import 'package:emerkit/features/heridas/presentation/heridas_screen.dart';
import 'package:emerkit/features/posiciones/presentation/posiciones_screen.dart';
import 'package:emerkit/features/cincinnati/presentation/cincinnati_screen.dart';
import 'package:emerkit/features/madrid_direct/presentation/madrid_direct_screen.dart';
import 'package:emerkit/features/hipotermia/presentation/hipotermia_screen.dart';
import 'package:emerkit/features/hipertermia/presentation/hipertermia_screen.dart';
import 'package:emerkit/features/comm/presentation/comm_screen.dart';
import 'package:emerkit/features/nihss/presentation/nihss_screen.dart';
import 'package:emerkit/features/rankin/presentation/rankin_screen.dart';
import 'package:emerkit/features/glosario/presentation/glosario_screen.dart';
import 'package:emerkit/features/respiratory_rate/presentation/respiratory_rate_screen.dart';

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
    GoRoute(
        path: '/o2-calculator', builder: (_, __) => const O2CalculatorScreen()),
    GoRoute(
        path: '/oxigenoterapia',
        builder: (_, __) => const OxigenoterapiaScreen()),
    GoRoute(path: '/ecg-leads', builder: (_, __) => const EcgLeadsScreen()),
    GoRoute(
        path: '/lund-browder', builder: (_, __) => const LundBrowderScreen()),
    GoRoute(path: '/rcp-rithm', builder: (_, __) => const RcpScreen()),
    GoRoute(path: '/plan-rcp', builder: (_, __) => const PlanRcpScreen()),
    GoRoute(path: '/adr', builder: (_, __) => const AdrScreen()),
    GoRoute(path: '/epi', builder: (_, __) => const EpiScreen()),
    GoRoute(path: '/vendajes', builder: (_, __) => const VendajesScreen()),
    GoRoute(path: '/heridas', builder: (_, __) => const HeridasScreen()),
    GoRoute(path: '/posiciones', builder: (_, __) => const PosicionesScreen()),
    GoRoute(path: '/cincinnati', builder: (_, __) => const CincinnatiScreen()),
    GoRoute(
        path: '/madrid-direct', builder: (_, __) => const MadridDirectScreen()),
    GoRoute(path: '/hipotermia', builder: (_, __) => const HipotermiaScreen()),
    GoRoute(
        path: '/hipertermia', builder: (_, __) => const HipertermiaScreen()),
    GoRoute(path: '/comm', builder: (_, __) => const CommScreen()),
    GoRoute(path: '/nihss', builder: (_, __) => const NihssScreen()),
    GoRoute(path: '/rankin', builder: (_, __) => const RankinScreen()),
    GoRoute(path: '/glosario', builder: (_, __) => const GlosarioScreen()),
    GoRoute(
        path: '/respiratory-rate',
        builder: (_, __) => const RespiratoryRateScreen()),
  ],
);
