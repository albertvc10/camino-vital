-- ============================================
-- TABLA: BIBLIOTECA DE EJERCICIOS
-- ============================================
-- Fecha: 3 Enero 2025
-- Propósito: Almacenar videos de ejercicios con clasificación automática por IA
-- Nota: Usar schema public (donde n8n trabaja por defecto)

-- ============================================
-- CREAR TABLA
-- ============================================
CREATE TABLE IF NOT EXISTS ejercicios_biblioteca (
  id SERIAL PRIMARY KEY,

  -- ==========================================
  -- INFO DEL VIDEO
  -- ==========================================
  nombre_archivo VARCHAR(255) NOT NULL UNIQUE,
  firebase_url TEXT,
  firebase_path TEXT,
  duracion_segundos INTEGER,

  -- ==========================================
  -- CLASIFICACIÓN AUTOMÁTICA POR IA
  -- ==========================================

  -- Nivel de dificultad
  nivel VARCHAR(50), -- 'iniciacion', 'intermedio', 'avanzado'

  -- Áreas del cuerpo que trabaja
  areas_cuerpo TEXT[], -- ['piernas', 'core', 'brazos', 'espalda', 'hombros', 'gluteos', 'pecho']

  -- Tipo de ejercicio
  tipo_ejercicio TEXT[], -- ['movilidad', 'fuerza', 'equilibrio', 'estiramiento', 'cardio', 'estabilidad']

  -- Posición en la que se realiza
  posicion VARCHAR(50), -- 'de_pie', 'sentado', 'suelo', 'tumbado', 'cuadrupedia'

  -- Equipo necesario
  requiere_equipo BOOLEAN DEFAULT false,
  equipo_necesario TEXT[], -- ['silla', 'banda_elastica', 'mancuernas', 'esterilla', 'pared']

  -- ==========================================
  -- COMPATIBILIDAD CON LIMITACIONES
  -- ==========================================
  -- Limitaciones con las que NO es compatible
  evitar_si_limitacion TEXT[], -- ['espalda', 'rodillas', 'hombros', 'munecas', 'cuello', 'cadera']

  -- ==========================================
  -- OBJETIVOS QUE CUMPLE
  -- ==========================================
  objetivos TEXT[], -- ['movilidad', 'fuerza', 'equilibrio', 'confianza', 'flexibilidad', 'postura']

  -- ==========================================
  -- CONTENIDO GENERADO POR IA
  -- ==========================================
  nombre_espanol VARCHAR(255), -- Nombre en español del ejercicio
  descripcion_corta TEXT, -- Descripción de 1-2 líneas
  descripcion_completa TEXT, -- Descripción detallada
  instrucciones_clave TEXT[], -- Array de pasos clave
  beneficios TEXT[], -- Beneficios del ejercicio
  precauciones TEXT[], -- Precauciones a tener en cuenta

  -- ==========================================
  -- METADATA
  -- ==========================================
  clasificado_por VARCHAR(50) DEFAULT 'ia', -- 'ia' o 'manual'
  verificado_manualmente BOOLEAN DEFAULT false,
  notas_admin TEXT,

  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- ÍNDICES para búsquedas rápidas
-- ============================================
CREATE INDEX IF NOT EXISTS idx_nivel ON ejercicios_biblioteca(nivel);
CREATE INDEX IF NOT EXISTS idx_posicion ON ejercicios_biblioteca(posicion);
CREATE INDEX IF NOT EXISTS idx_areas ON ejercicios_biblioteca USING GIN(areas_cuerpo);
CREATE INDEX IF NOT EXISTS idx_tipos ON ejercicios_biblioteca USING GIN(tipo_ejercicio);
CREATE INDEX IF NOT EXISTS idx_objetivos ON ejercicios_biblioteca USING GIN(objetivos);
CREATE INDEX IF NOT EXISTS idx_limitaciones ON ejercicios_biblioteca USING GIN(evitar_si_limitacion);

-- ============================================
-- COMENTARIOS
-- ============================================
COMMENT ON TABLE ejercicios_biblioteca IS 'Biblioteca de videos de ejercicios clasificados automáticamente por IA';
COMMENT ON COLUMN ejercicios_biblioteca.nombre_archivo IS 'Nombre original del archivo en Firebase';
COMMENT ON COLUMN ejercicios_biblioteca.nivel IS 'Nivel de dificultad: iniciacion, intermedio, avanzado';
COMMENT ON COLUMN ejercicios_biblioteca.areas_cuerpo IS 'Áreas del cuerpo que trabaja el ejercicio';
COMMENT ON COLUMN ejercicios_biblioteca.evitar_si_limitacion IS 'Limitaciones físicas con las que no es recomendable';

-- ============================================
-- TRIGGER: Actualizar updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_ejercicios_biblioteca_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_ejercicios_biblioteca_timestamp
  BEFORE UPDATE ON ejercicios_biblioteca
  FOR EACH ROW
  EXECUTE FUNCTION update_ejercicios_biblioteca_timestamp();

-- ============================================
-- VERIFICACIÓN
-- ============================================
SELECT
  'Tabla creada: ejercicios_biblioteca' as resultado,
  COUNT(*) as total_ejercicios
FROM ejercicios_biblioteca;
