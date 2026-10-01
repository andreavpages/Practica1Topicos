-- ============================================================
-- PRÁCTICA 01 - AGENTE DE GESTIÓN DE INSCRIPCIONES
-- Base de datos: Academia de Cursos Online
-- PostgreSQL / Supabase
-- ============================================================


-- ============================================================
-- 1. TABLA: CURSOS
-- ============================================================

CREATE TABLE IF NOT EXISTS cursos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    modalidad VARCHAR(50) NOT NULL DEFAULT 'Online',
    cupos_disponibles INT NOT NULL CHECK (cupos_disponibles >= 0),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 2. TABLA: ESTUDIANTES
-- ============================================================

CREATE TABLE IF NOT EXISTS estudiantes (
    id SERIAL PRIMARY KEY,
    telegram_chat_id BIGINT UNIQUE NOT NULL,
    nombre_completo VARCHAR(150) NOT NULL,
    cedula_identidad VARCHAR(30) UNIQUE NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telefono VARCHAR(30),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 3. TABLA: INSCRIPCIONES
-- ============================================================

CREATE TABLE IF NOT EXISTS inscripciones (
    id SERIAL PRIMARY KEY,

    estudiante_id INT NOT NULL,
    curso_id INT NOT NULL,

    estado VARCHAR(30) NOT NULL DEFAULT 'completada'
        CHECK (estado IN (
            'iniciada',
            'completada',
            'cancelada'
        )),

    metodo_pago VARCHAR(50) NOT NULL,

    referencia_pago VARCHAR(100),

    fecha_inscripcion TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    -- Un estudiante no puede inscribirse dos veces
    -- en el mismo curso.
    CONSTRAINT uq_estudiante_curso
        UNIQUE (estudiante_id, curso_id),

    -- Relación con estudiantes.
    CONSTRAINT fk_inscripcion_estudiante
        FOREIGN KEY (estudiante_id)
        REFERENCES estudiantes(id)
        ON DELETE CASCADE,

    -- Relación con cursos.
    CONSTRAINT fk_inscripcion_curso
        FOREIGN KEY (curso_id)
        REFERENCES cursos(id)
        ON DELETE RESTRICT
);


-- ============================================================
-- 4. ÍNDICES
-- ============================================================

-- Facilita las búsquedas de inscripciones por estudiante.
CREATE INDEX IF NOT EXISTS idx_inscripciones_estudiante
    ON inscripciones(estudiante_id);

-- Facilita las búsquedas de inscripciones por curso.
CREATE INDEX IF NOT EXISTS idx_inscripciones_curso
    ON inscripciones(curso_id);

-- Facilita la búsqueda de cursos activos.
CREATE INDEX IF NOT EXISTS idx_cursos_activo
    ON cursos(activo);


-- ============================================================
-- 5. DATOS DE PRUEBA - CURSOS
-- ============================================================

INSERT INTO cursos (
    nombre,
    descripcion,
    modalidad,
    cupos_disponibles,
    activo
)
VALUES
(
    'Fundamentos de Bases de Datos SQL',
    'Aprende modelado relacional, consultas avanzadas y optimización.',
    'Online',
    15,
    TRUE
),
(
    'Desarrollo de Agentes de IA y Automatización',
    'Construcción de agentes conversacionales y flujos de trabajo.',
    'Online',
    10,
    TRUE
),
(
    'Ciberseguridad Ofensiva Práctica',
    'Taller intensivo de auditoría y análisis de vulnerabilidades.',
    'Online',
    0,
    TRUE
)
ON CONFLICT DO NOTHING;


-- ============================================================
-- 6. CONSULTAS DE VERIFICACIÓN
-- ============================================================

-- Ver cursos registrados.
SELECT
    id,
    nombre,
    modalidad,
    cupos_disponibles,
    activo
FROM cursos
ORDER BY id;


-- Ver estudiantes registrados.
SELECT
    id,
    telegram_chat_id,
    nombre_completo,
    cedula_identidad,
    email,
    telefono
FROM estudiantes
ORDER BY id;


-- Ver inscripciones realizadas.
SELECT
    i.id AS numero_inscripcion,
    e.nombre_completo AS estudiante,
    e.cedula_identidad,
    e.email,
    c.nombre AS curso,
    i.metodo_pago,
    i.estado,
    i.fecha_inscripcion
FROM inscripciones i
INNER JOIN estudiantes e
    ON i.estudiante_id = e.id
INNER JOIN cursos c
    ON i.curso_id = c.id
ORDER BY i.id;