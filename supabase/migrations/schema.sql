-- 1. Tabla de Cursos
CREATE TABLE IF NOT EXISTS cursos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    modalidad VARCHAR(50) DEFAULT 'Online',
    cupos_disponibles INT NOT NULL CHECK (cupos_disponibles >= 0),
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Tabla de Estudiantes
CREATE TABLE IF NOT EXISTS estudiantes (
    id SERIAL PRIMARY KEY,
    telegram_chat_id BIGINT UNIQUE NOT NULL,
    nombre_completo VARCHAR(150) NOT NULL,
    cedula_identidad VARCHAR(30) UNIQUE NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telefono VARCHAR(30),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Tabla de Inscripciones
CREATE TABLE IF NOT EXISTS inscripciones (
    id SERIAL PRIMARY KEY,
    estudiante_id INT REFERENCES estudiantes(id) ON DELETE CASCADE,
    curso_id INT REFERENCES cursos(id) ON DELETE RESTRICT,
    estado VARCHAR(30) DEFAULT 'completada' CHECK (estado IN ('iniciada', 'completada', 'cancelada')),
    referencia_pago VARCHAR(100),
    fecha_inscripcion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT uq_estudiante_curso UNIQUE (estudiante_id, curso_id)
);

-- 4. Datos de prueba iniciales
INSERT INTO cursos (nombre, descripcion, cupos_disponibles, activo)
VALUES 
('Fundamentos de Bases de Datos SQL', 'Aprende modelado relacional, consultas avanzadas y optimización.', 15, TRUE),
('Desarrollo de Agentes de IA y Automatización', 'Construcción de agentes conversacionales y flujos de trabajo.', 10, TRUE),
('Ciberseguridad Ofensiva Práctica', 'Taller intensivo de auditoría y análisis de vulnerabilidades.', 0, TRUE)
ON CONFLICT DO NOTHING;