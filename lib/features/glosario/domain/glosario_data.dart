import 'package:navaja_suiza_sanitaria/shared/domain/entities/clinical_reference.dart';

class GlosarioEntry {
  final String term;
  final String definition;

  const GlosarioEntry(this.term, this.definition);
}

class GlosarioData {
  GlosarioData._();

  static const entries = <GlosarioEntry>[
    // A
    GlosarioEntry(
      'Anafilaxia',
      'Reaccion alergica grave y generalizada de instauracion rapida que puede '
          'comprometer la via aerea, la respiracion y la circulacion. Tratamiento '
          'de eleccion: adrenalina IM.',
    ),
    GlosarioEntry(
      'Angina de pecho',
      'Dolor toracico opresivo por isquemia miocardica transitoria. Se alivia '
          'con reposo o nitroglicerina sublingual.',
    ),
    GlosarioEntry(
      'Anisocoria',
      'Diferencia de tamano entre ambas pupilas. Puede indicar lesion '
          'intracraneal, herniacion o afectacion del III par craneal.',
    ),
    GlosarioEntry(
      'Apnea',
      'Cese completo de la respiracion. Requiere ventilacion asistida '
          'inmediata si se prolonga.',
    ),
    GlosarioEntry(
      'Arritmia',
      'Alteracion del ritmo cardiaco normal. Puede ser taquicardia, '
          'bradicardia o ritmos irregulares. Algunas son potencialmente letales.',
    ),
    GlosarioEntry(
      'Asistolia',
      'Ausencia total de actividad electrica cardiaca. Es un ritmo de parada '
          'cardiaca no desfibrilable. Tratamiento: RCP y adrenalina.',
    ),
    GlosarioEntry(
      'Aspiracion',
      'Entrada de contenido gastrico, sangre u otros fluidos en la via aerea '
          'inferior. Riesgo en pacientes con bajo nivel de consciencia.',
    ),
    GlosarioEntry(
      'AVDN',
      'Escala rapida de valoracion neurologica: Alerta, respuesta Verbal, '
          'respuesta al Dolor, No responde. Alternativa rapida al Glasgow.',
    ),
    // B
    GlosarioEntry(
      'Barotrauma',
      'Lesion tisular causada por cambios de presion, frecuente en ventilacion '
          'mecanica con presiones elevadas. Puede provocar neumotorax.',
    ),
    GlosarioEntry(
      'Bradicardia',
      'Frecuencia cardiaca inferior a 60 lpm. Puede ser fisiologica o '
          'patologica. Si hay inestabilidad hemodinamica, tratar con atropina.',
    ),
    GlosarioEntry(
      'Bradipnea',
      'Frecuencia respiratoria anormalmente baja (<12 rpm en adultos). '
          'Puede indicar depresion del SNC, hipotermia o intoxicacion.',
    ),
    GlosarioEntry(
      'Broncoespasmo',
      'Contraccion de la musculatura lisa bronquial que produce estrechamiento '
          'de la via aerea, sibilancias y dificultad respiratoria.',
    ),
    // C
    GlosarioEntry(
      'Capnografia',
      'Monitorizacion continua del CO2 al final de la espiracion (EtCO2). '
          'Confirma intubacion correcta y calidad de RCP.',
    ),
    GlosarioEntry(
      'Cardioversion',
      'Descarga electrica sincronizada con la onda R para revertir '
          'taquiarritmias con pulso. Requiere sedacion previa.',
    ),
    GlosarioEntry(
      'Cianosis',
      'Coloracion azulada de piel y mucosas por exceso de hemoglobina '
          'desoxigenada. Indica hipoxemia significativa.',
    ),
    GlosarioEntry(
      'Coagulopatia',
      'Trastorno de la coagulacion sanguinea que predispone a hemorragia '
          'o trombosis. Frecuente en politrauma y sepsis.',
    ),
    GlosarioEntry(
      'Collarín cervical',
      'Dispositivo de inmovilizacion cervical. Se coloca ante sospecha de '
          'lesion de columna cervical para evitar lesiones medulares.',
    ),
    GlosarioEntry(
      'Cricotirotomia',
      'Tecnica quirurgica de emergencia para acceder a la via aerea a traves '
          'de la membrana cricotiroidea. Indicada cuando la intubacion falla.',
    ),
    // D
    GlosarioEntry(
      'DEA',
      'Desfibrilador Externo Automatizado. Dispositivo que analiza el ritmo '
          'cardiaco y administra descarga si detecta ritmo desfibrilable (FV/TVSP).',
    ),
    GlosarioEntry(
      'Desfibrilacion',
      'Descarga electrica no sincronizada para revertir fibrilacion '
          'ventricular o taquicardia ventricular sin pulso.',
    ),
    GlosarioEntry(
      'Diaforesis',
      'Sudoracion profusa. Signo frecuente de dolor intenso, hipoglucemia, '
          'infarto agudo de miocardio o shock.',
    ),
    GlosarioEntry(
      'Disnea',
      'Dificultad respiratoria o sensacion subjetiva de falta de aire. '
          'Puede tener origen cardiaco, pulmonar o metabolico.',
    ),
    // E
    GlosarioEntry(
      'Edema',
      'Acumulacion de liquido en el espacio intersticial. El edema pulmonar '
          'es una emergencia que compromete la oxigenacion.',
    ),
    GlosarioEntry(
      'Edema agudo de pulmon',
      'Acumulacion rapida de liquido en los alveolos pulmonares, generalmente '
          'de causa cardiogenica. Tratamiento: oxigeno, diureticos, nitratos.',
    ),
    GlosarioEntry(
      'Emesis',
      'Vomito. En pacientes con bajo nivel de consciencia supone riesgo de '
          'aspiracion. Colocar en PLS si no hay contraindicacion.',
    ),
    GlosarioEntry(
      'Enfisema subcutaneo',
      'Presencia de aire en el tejido subcutaneo, palpable como crepitacion. '
          'Puede asociarse a neumotorax o lesion traqueal.',
    ),
    GlosarioEntry(
      'Epiglotitis',
      'Inflamacion de la epiglotis que puede obstruir la via aerea '
          'rapidamente. Mas frecuente en ninos. No manipular la orofaringe.',
    ),
    GlosarioEntry(
      'Estridor',
      'Sonido respiratorio agudo causado por obstruccion de la via aerea '
          'superior. Indica compromiso significativo del flujo aereo.',
    ),
    GlosarioEntry(
      'EtCO2',
      'CO2 al final de la espiracion (End-Tidal CO2). Valor normal: 35-45 '
          'mmHg. Util para confirmar intubacion y evaluar perfusion en RCP.',
    ),
    GlosarioEntry(
      'Evisceracion',
      'Salida de organos abdominales a traves de una herida. Cubrir con '
          'gasas humedas esteriles, no reintroducir.',
    ),
    // F
    GlosarioEntry(
      'Fibrilacion auricular',
      'Arritmia con actividad auricular desorganizada y respuesta ventricular '
          'irregular. Riesgo de ictus por formacion de trombos.',
    ),
    GlosarioEntry(
      'Fibrilacion ventricular',
      'Actividad electrica cardiaca caotica sin contraccion efectiva. '
          'Ritmo de parada desfibrilable. Tratamiento: desfibrilacion inmediata.',
    ),
    GlosarioEntry(
      'FiO2',
      'Fraccion inspirada de oxigeno. El aire ambiente tiene FiO2 de 0,21 '
          '(21%). Los dispositivos de oxigenoterapia permiten aumentarla.',
    ),
    GlosarioEntry(
      'Flail chest',
      'Torax inestable. Fractura de 3 o mas costillas consecutivas en 2 '
          'puntos. Produce respiracion paradojica y compromiso ventilatorio.',
    ),
    // G
    GlosarioEntry(
      'GCS (Glasgow)',
      'Escala de Coma de Glasgow. Valora el nivel de consciencia mediante '
          'respuesta ocular (1-4), verbal (1-5) y motora (1-6). Rango: 3-15.',
    ),
    GlosarioEntry(
      'Glucometria',
      'Medicion de glucosa en sangre capilar. Valores normales: 70-110 mg/dL '
          'en ayunas. Imprescindible en alteracion de consciencia.',
    ),
    GlosarioEntry(
      'Guedel',
      'Canula orofaringea que mantiene la via aerea permeable impidiendo '
          'la caida de la lengua. Solo en pacientes inconscientes sin reflejo nauseoso.',
    ),
    // H
    GlosarioEntry(
      'Hemoptisis',
      'Expulsion de sangre por la boca procedente del tracto respiratorio. '
          'Puede indicar lesion pulmonar, embolia o infeccion.',
    ),
    GlosarioEntry(
      'Hemorragia',
      'Salida de sangre de los vasos sanguineos. Se clasifica en externa e '
          'interna, y por severidad en clases I a IV segun volumen perdido.',
    ),
    GlosarioEntry(
      'Hemostasia',
      'Conjunto de mecanismos para detener una hemorragia. En emergencias: '
          'presion directa, torniquete o agentes hemostaticos.',
    ),
    GlosarioEntry(
      'Hemotorax',
      'Acumulacion de sangre en la cavidad pleural. Puede comprometer la '
          'ventilacion y causar shock hipovolemico.',
    ),
    GlosarioEntry(
      'Hiperglucemia',
      'Glucosa en sangre elevada (>180 mg/dL). Puede causar cetoacidosis '
          'diabetica o estado hiperglucemico hiperosmolar.',
    ),
    GlosarioEntry(
      'Hipoglucemia',
      'Glucosa en sangre baja (<60 mg/dL). Puede causar confusion, '
          'convulsiones y perdida de consciencia. Tratar con glucosa.',
    ),
    GlosarioEntry(
      'Hipotension',
      'Presion arterial baja (PAS <90 mmHg). Puede indicar shock, '
          'hemorragia, deshidratacion o anafilaxia.',
    ),
    GlosarioEntry(
      'Hipotermia',
      'Temperatura corporal central <35 °C. Clasificacion: leve (35-32 °C), '
          'moderada (32-28 °C), grave (<28 °C). Riesgo de arritmias.',
    ),
    GlosarioEntry(
      'Hipovolemia',
      'Disminucion del volumen sanguineo circulante. Causa frecuente de '
          'shock en trauma. Signos: taquicardia, hipotension, palidez.',
    ),
    GlosarioEntry(
      'Hipoxemia',
      'Disminucion de la presion parcial de oxigeno en sangre arterial '
          '(PaO2 <60 mmHg). Puede causar hipoxia tisular.',
    ),
    GlosarioEntry(
      'Hipoxia',
      'Deficit de oxigeno en los tejidos. Puede ser por hipoxemia, anemia, '
          'isquemia o intoxicacion por CO. Requiere oxigenoterapia.',
    ),
    // I
    GlosarioEntry(
      'IAM',
      'Infarto Agudo de Miocardio. Necrosis del musculo cardiaco por '
          'isquemia prolongada. Codigo tiempo: activacion precoz del sistema.',
    ),
    GlosarioEntry(
      'Inmovilizacion',
      'Restriccion del movimiento de una zona del cuerpo. Esencial en '
          'fracturas, luxaciones y sospecha de lesion medular.',
    ),
    GlosarioEntry(
      'Intubacion orotraqueal',
      'Insercion de un tubo endotraqueal a traves de la boca para asegurar '
          'la via aerea. Indicada en GCS <=8 o fallo ventilatorio.',
    ),
    GlosarioEntry(
      'IOT',
      'Intubacion OroTraqueal. Acronimo habitual para referirse a la '
          'intubacion endotraqueal por via oral.',
    ),
    GlosarioEntry(
      'Isquemia',
      'Deficit de aporte sanguineo a un tejido. Produce dano celular '
          'reversible que, si persiste, evoluciona a necrosis.',
    ),
    // L
    GlosarioEntry(
      'Laceración',
      'Herida producida por desgarro de los tejidos con bordes irregulares. '
          'Frecuente en traumatismos con objetos romos.',
    ),
    GlosarioEntry(
      'Laringoscopia',
      'Visualizacion directa de la laringe con un laringoscopio. Se realiza '
          'para la intubacion orotraqueal.',
    ),
    // M
    GlosarioEntry(
      'Maniobra de Heimlich',
      'Compresiones abdominales subdiafragmaticas para desobstruir la via '
          'aerea en atragantamiento. En embarazadas y obesos: compresiones toracicas.',
    ),
    GlosarioEntry(
      'Maniobra frente-menton',
      'Apertura de via aerea basica inclinando la cabeza hacia atras y '
          'elevando el menton. Contraindicada si se sospecha lesion cervical.',
    ),
    GlosarioEntry(
      'Midriasis',
      'Dilatacion pupilar. Bilateral y arreactiva indica dano cerebral '
          'grave. Unilateral puede indicar herniacion uncal.',
    ),
    GlosarioEntry(
      'Miosis',
      'Constriccion pupilar. Bilateral en intoxicacion por opiaceos, '
          'organofosforados o lesion pontina.',
    ),
    GlosarioEntry(
      'Monitorizacion',
      'Vigilancia continua de parametros vitales: ECG, SpO2, TA, FR, '
          'temperatura y EtCO2. Fundamental en el paciente critico.',
    ),
    // N
    GlosarioEntry(
      'Neumotorax',
      'Presencia de aire en la cavidad pleural que provoca colapso pulmonar. '
          'El neumotorax a tension es una emergencia vital.',
    ),
    GlosarioEntry(
      'Neumotorax a tension',
      'Acumulacion progresiva de aire en pleura con efecto valvular. '
          'Causa colapso cardiopulmonar. Descompresion inmediata con aguja.',
    ),
    GlosarioEntry(
      'NIHSS',
      'National Institutes of Health Stroke Scale. Escala de valoracion '
          'neurologica del ictus. Rango 0-42, mayor puntuacion indica mayor gravedad.',
    ),
    // O
    GlosarioEntry(
      'OPQRST',
      'Nemotecnia para valorar el dolor: Onset (inicio), Provocacion, '
          'Quality (calidad), Radiacion, Severity (intensidad), Tiempo.',
    ),
    GlosarioEntry(
      'Orofaringea (canula)',
      'Canula de Guedel. Dispositivo que mantiene la via aerea permeable. '
          'Medir desde comisura labial hasta angulo mandibular.',
    ),
    GlosarioEntry(
      'Oximetria de pulso',
      'Medicion no invasiva de la saturacion de oxigeno (SpO2) mediante '
          'pulsioximetro. Normal: 95-100%. Urgente si <90%.',
    ),
    // P
    GlosarioEntry(
      'Parada cardiorrespiratoria',
      'Cese brusco e inesperado de la actividad cardiaca y respiratoria. '
          'Requiere RCP inmediata y desfibrilacion precoz si esta indicada.',
    ),
    GlosarioEntry(
      'PCR',
      'Parada CardioRespiratoria. Cese subito de la circulacion y '
          'ventilacion. Activar cadena de supervivencia de forma inmediata.',
    ),
    GlosarioEntry(
      'Perfusion',
      'Flujo de sangre a traves de los tejidos. Se valora mediante relleno '
          'capilar (normal <2 segundos), color y temperatura de la piel.',
    ),
    GlosarioEntry(
      'PLS',
      'Posicion Lateral de Seguridad. Posicion de recuperacion para pacientes '
          'inconscientes que respiran. Previene aspiracion.',
    ),
    GlosarioEntry(
      'Precordial',
      'Relativo a la region anterior del torax sobre el corazon. Zona de '
          'aplicacion del golpe precordial y de compresiones toracicas.',
    ),
    GlosarioEntry(
      'Presion arterial',
      'Fuerza que ejerce la sangre sobre las paredes arteriales. Normal: '
          '120/80 mmHg. Hipertension: >=140/90. Hipotension: PAS <90.',
    ),
    // R
    GlosarioEntry(
      'RCP',
      'Reanimacion CardioPulmonar. Compresiones toracicas (100-120/min, '
          '5-6 cm) y ventilaciones para mantener la circulacion en PCR.',
    ),
    GlosarioEntry(
      'Relleno capilar',
      'Tiempo que tarda en recuperarse el color tras presionar el lecho '
          'ungueal. Normal <2 seg. Prolongado indica mala perfusion.',
    ),
    GlosarioEntry(
      'ROSC',
      'Return Of Spontaneous Circulation. Retorno de la circulacion '
          'espontanea tras PCR. Signos: pulso palpable, EtCO2 >40, movimientos.',
    ),
    // S
    GlosarioEntry(
      'SAMPLE',
      'Nemotecnia para la anamnesis: Sintomas, Alergias, Medicacion, '
          'Patologias previas, Libaciones (ultima ingesta), Eventos previos.',
    ),
    GlosarioEntry(
      'Saturacion de oxigeno',
      'Porcentaje de hemoglobina unida a oxigeno (SpO2). Normal: 95-100%. '
          '<94% indica hipoxemia. <90% requiere intervencion inmediata.',
    ),
    GlosarioEntry(
      'SBAR',
      'Situacion, Background (antecedentes), Assessment (evaluacion), '
          'Recommendation. Metodo estructurado de comunicacion clinica.',
    ),
    GlosarioEntry(
      'Shock',
      'Insuficiencia circulatoria aguda con hipoperfusion tisular. Tipos: '
          'hipovolemico, cardiogenico, distributivo y obstructivo.',
    ),
    GlosarioEntry(
      'Shock anafilactico',
      'Forma mas grave de anafilaxia con colapso cardiovascular. '
          'Tratamiento: adrenalina IM 0,3-0,5 mg, fluidos IV y oxigeno.',
    ),
    GlosarioEntry(
      'Shock hipovolemico',
      'Shock por perdida de volumen intravascular (hemorragia, quemaduras, '
          'deshidratacion). Signos: taquicardia, hipotension, palidez.',
    ),
    GlosarioEntry(
      'Sibilancias',
      'Sonidos espiratorios agudos por estrechamiento bronquial. '
          'Frecuentes en asma, EPOC y broncoespasmo.',
    ),
    GlosarioEntry(
      'Sincope',
      'Perdida transitoria de consciencia por hipoperfusion cerebral '
          'global. Recuperacion espontanea y completa.',
    ),
    GlosarioEntry(
      'SVB',
      'Soporte Vital Basico. Maniobras de RCP sin equipamiento avanzado: '
          'compresiones, ventilaciones, DEA. Primer eslabon de la cadena.',
    ),
    GlosarioEntry(
      'SVA',
      'Soporte Vital Avanzado. Incluye manejo avanzado de via aerea, '
          'farmacos, monitorizacion y tratamiento de arritmias en PCR.',
    ),
    // T
    GlosarioEntry(
      'Taquicardia',
      'Frecuencia cardiaca superior a 100 lpm. Puede ser sinusal, '
          'supraventricular o ventricular. Tratar segun estabilidad.',
    ),
    GlosarioEntry(
      'Taquipnea',
      'Frecuencia respiratoria elevada (>20 rpm en adultos). Signo de '
          'dificultad respiratoria, dolor, ansiedad o acidosis metabolica.',
    ),
    GlosarioEntry(
      'Taponamiento cardiaco',
      'Acumulacion de liquido en el pericardio que comprime el corazon e '
          'impide su llenado. Triada de Beck: hipotension, ingurgitacion '
          'yugular, tonos apagados.',
    ),
    GlosarioEntry(
      'TEP',
      'Triangulo de Evaluacion Pediatrica. Valoracion rapida de apariencia, '
          'trabajo respiratorio y circulacion cutanea en ninos.',
    ),
    GlosarioEntry(
      'Torniquete',
      'Dispositivo de compresion circunferencial para control de hemorragias '
          'graves en extremidades. Anotar hora de colocacion.',
    ),
    GlosarioEntry(
      'Traumatismo craneoencefalico',
      'Lesion traumatica del craneo y/o cerebro. Clasificacion por GCS: '
          'leve (14-15), moderado (9-13), grave (3-8).',
    ),
    GlosarioEntry(
      'Trendelenburg',
      'Posicion con la cabeza mas baja que los pies (15-30 grados). '
          'Indicada en shock hipovolemico para favorecer retorno venoso.',
    ),
    GlosarioEntry(
      'Triage',
      'Sistema de clasificacion de pacientes por gravedad para priorizar '
          'la atencion. START es el metodo mas utilizado en incidentes multiples.',
    ),
    GlosarioEntry(
      'TVSP',
      'Taquicardia Ventricular Sin Pulso. Ritmo de parada cardiaca '
          'desfibrilable. Tratamiento: desfibrilacion inmediata.',
    ),
    // V
    GlosarioEntry(
      'Ventilacion',
      'Proceso de entrada y salida de aire de los pulmones. En emergencias: '
          'ventilacion asistida con balon resucitador o ventilador mecanico.',
    ),
    GlosarioEntry(
      'Ventilacion mecanica',
      'Soporte ventilatorio mediante un dispositivo mecanico. Indicada en '
          'insuficiencia respiratoria grave o pacientes intubados.',
    ),
    GlosarioEntry(
      'Via aerea',
      'Conducto por el que circula el aire desde la nariz/boca hasta los '
          'alveolos. Su manejo es la primera prioridad (A del ABCDE).',
    ),
    GlosarioEntry(
      'Via intraosea',
      'Acceso vascular de emergencia a traves de la medula osea. Indicada '
          'cuando no se puede obtener un acceso intravenoso rapido.',
    ),
    GlosarioEntry(
      'Volumen tidal',
      'Volumen de aire que se moviliza en cada respiracion normal. '
          'Aproximadamente 6-7 mL/kg en ventilacion mecanica protectora.',
    ),
    // X
    GlosarioEntry(
      'Xifoides',
      'Apendice cartilaginoso inferior del esternon. Referencia anatomica '
          'para la colocacion de las manos en compresiones toracicas (justo por encima).',
    ),
  ];

  static const infoSections = <String, String>{
    '¿Que es?':
        'El glosario de emergencias contiene los terminos mas utilizados en la '
            'atencion sanitaria de urgencias y emergencias. Esta pensado como '
            'referencia rapida para profesionales y estudiantes del ambito '
            'prehospitalario y hospitalario.',
    'Como usar':
        'Utiliza la barra de busqueda para encontrar un termino rapidamente. '
            'La busqueda filtra tanto por el nombre del termino como por su '
            'definicion, permitiendote encontrar conceptos aunque no recuerdes '
            'el nombre exacto.',
    'Contenido':
        'Incluye terminologia de soporte vital, valoracion neurologica, '
            'trauma, farmacologia, tecnicas, monitorizacion y comunicacion '
            'clinica. Las definiciones son concisas y orientadas a la practica.',
  };

  static const references = [
    ClinicalReference(
      'ERC Guidelines 2025. European Resuscitation Council.',
    ),
    ClinicalReference(
      'PHTLS: Prehospital Trauma Life Support. 10th Ed. Jones & Bartlett.',
    ),
    ClinicalReference(
      'ATLS: Advanced Trauma Life Support. 10th Ed. ACS, 2018.',
    ),
    ClinicalReference(
      'Tintinalli\'s Emergency Medicine. 9th Ed. McGraw-Hill, 2020.',
    ),
  ];
}
