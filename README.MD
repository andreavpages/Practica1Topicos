# Práctica 01 — Agente de Gestión de Inscripciones

Agente conversacional para la gestión de inscripciones a cursos online mediante Telegram, desarrollado utilizando n8n y una base de datos PostgreSQL alojada en Supabase.

---

## 📋 Descripción

El proyecto corresponde a la Práctica 01 de la asignatura **Tópicos Especiales para la Gestión de Datos**.

El objetivo es desarrollar un agente conversacional que permita a un usuario realizar el proceso de inscripción a un curso mediante Telegram.

El agente permite:

* Capturar los datos del estudiante.
* Consultar los cursos disponibles.
* Validar la disponibilidad de cupos.
* Validar los datos proporcionados por el usuario.
* Registrar la inscripción de forma persistente.
* Generar un número de inscripción.
* Enviar una confirmación al usuario mediante Telegram.
* Informar al usuario cuando un curso no tenga cupos disponibles.
* Manejar datos incompletos o inválidos.

---

## 🏗️ Arquitectura del proyecto

El proyecto utiliza los siguientes componentes:

```text
┌─────────────────┐
│    Telegram     │
│     Usuario     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│      n8n        │
│     Agente      │
└────────┬────────┘
         │
         │ Consultas / Registros
         ▼
┌─────────────────┐
│    Supabase     │
│   PostgreSQL    │
└─────────────────┘
```

### Tecnologías utilizadas

* **Telegram** — Interfaz de comunicación con el usuario.
* **n8n** — Automatización y ejecución del flujo conversacional.
* **Supabase** — Plataforma utilizada para alojar la base de datos PostgreSQL.
* **PostgreSQL** — Sistema gestor de base de datos.
* **GitHub** — Control de versiones y almacenamiento del código del proyecto.

---

## 📁 Estructura del repositorio

```text
practica1/
│
├── supabase/
│   └── migrations/
│       └── 20260930200000_initial_schema.sql
│
├── workflows/
│   └── agente_gestion_inscripciones.json
│
└── README.md
```

### `supabase/migrations/`

Contiene las migraciones SQL utilizadas para crear y configurar la base de datos.

### `workflows/`

Contiene el workflow exportado de n8n correspondiente al agente de gestión de inscripciones.

### `README.md`

Contiene la documentación del proyecto, instalación, configuración y pruebas.

---

# 🗄️ Base de datos

La base de datos está implementada en PostgreSQL mediante Supabase.

Se utilizan tres tablas principales:

```text
CURSOS
   │
   │ 1:N
   ▼
INSCRIPCIONES
   ▲
   │ N:1
   │
ESTUDIANTES
```

---

## Tabla `cursos`

Almacena la información de los cursos disponibles.

| Campo               | Tipo         | Descripción                        |
| ------------------- | ------------ | ---------------------------------- |
| `id`                | SERIAL       | Identificador del curso            |
| `nombre`            | VARCHAR(150) | Nombre del curso                   |
| `descripcion`       | TEXT         | Descripción del curso              |
| `modalidad`         | VARCHAR(50)  | Modalidad del curso                |
| `cupos_disponibles` | INT          | Cantidad de cupos disponibles      |
| `activo`            | BOOLEAN      | Indica si el curso está disponible |
| `created_at`        | TIMESTAMP    | Fecha de creación                  |

---

## Tabla `estudiantes`

Almacena los datos de los usuarios que realizan inscripciones.

| Campo              | Tipo         | Descripción                        |
| ------------------ | ------------ | ---------------------------------- |
| `id`               | SERIAL       | Identificador del estudiante       |
| `telegram_chat_id` | BIGINT       | Identificador del chat de Telegram |
| `nombre_completo`  | VARCHAR(150) | Nombre completo                    |
| `cedula_identidad` | VARCHAR(30)  | Documento de identidad             |
| `email`            | VARCHAR(150) | Correo electrónico                 |
| `telefono`         | VARCHAR(30)  | Número telefónico                  |
| `created_at`       | TIMESTAMP    | Fecha de creación                  |

---

## Tabla `inscripciones`

Registra las inscripciones realizadas.

| Campo               | Tipo         | Descripción                           |
| ------------------- | ------------ | ------------------------------------- |
| `id`                | SERIAL       | Número de inscripción                 |
| `estudiante_id`     | INT          | Estudiante que realiza la inscripción |
| `curso_id`          | INT          | Curso seleccionado                    |
| `estado`            | VARCHAR(30)  | Estado de la inscripción              |
| `metodo_pago`       | VARCHAR(50)  | Método de pago seleccionado           |
| `referencia_pago`   | VARCHAR(100) | Referencia del pago                   |
| `fecha_inscripcion` | TIMESTAMP    | Fecha de la inscripción               |

Un estudiante no puede tener más de una inscripción para el mismo curso.

---

# 🔄 Flujo del agente

El flujo general del agente es:

```text
Usuario inicia conversación
        │
        ▼
Solicitar nombre completo
        │
        ▼
Solicitar documento de identidad
        │
        ▼
Solicitar correo electrónico
        │
        ▼
Mostrar/solicitar curso
        │
        ▼
Consultar disponibilidad
        │
        ├───────────────┐
        │               │
     Hay cupos       Sin cupos
        │               │
        ▼               ▼
Solicitar método    Informar al
de pago             usuario
        │
        ▼
Validar información
        │
        ├───────────────┐
        │               │
      Válida         Inválida
        │               │
        ▼               ▼
Registrar          Solicitar
inscripción        corrección
        │
        ▼
Generar número
de inscripción
        │
        ▼
Enviar confirmación
por Telegram
```

---

# 📝 Datos solicitados al usuario

Para realizar una inscripción se solicita:

1. Nombre completo.
2. Documento de identidad.
3. Correo electrónico.
4. Curso de interés.
5. Método de pago.

Opcionalmente puede solicitarse el número telefónico.

---

# ✅ Validaciones

Antes de registrar una inscripción, el agente debe comprobar:

### Disponibilidad del curso

El curso debe:

* Existir en la base de datos.
* Estar activo.
* Tener al menos un cupo disponible.

### Datos del estudiante

Los datos proporcionados deben estar completos y cumplir con las validaciones correspondientes.

### Inscripción duplicada

Un estudiante no puede registrarse dos veces en el mismo curso.

---

# ⚠️ Manejo de errores

El agente contempla, como mínimo, los siguientes escenarios:

## Curso sin cupos

Si `cupos_disponibles = 0`, la inscripción no se realiza y se informa al usuario que el curso no tiene cupos disponibles.

## Datos incompletos o inválidos

Si el usuario proporciona información incompleta o inválida, el agente solicita nuevamente el dato correspondiente antes de continuar.

## Curso inexistente

Si el curso indicado por el usuario no existe en la base de datos, se informa al usuario y se solicita seleccionar un curso válido.

## Inscripción duplicada

Si el estudiante ya está inscrito en el curso seleccionado, no se crea una nueva inscripción.

---

# 🧪 Datos de prueba

La base de datos contiene inicialmente los siguientes cursos:

| Curso                                        | Cupos |
| -------------------------------------------- | ----: |
| Fundamentos de Bases de Datos SQL            |    15 |
| Desarrollo de Agentes de IA y Automatización |    10 |
| Ciberseguridad Ofensiva Práctica             |     0 |

El curso de **Ciberseguridad Ofensiva Práctica** se encuentra inicialmente sin cupos para permitir la demostración del escenario de error correspondiente.

---

# ⚙️ Configuración

## 1. Clonar el repositorio

```bash
git clone URL_DEL_REPOSITORIO
```

Entrar al proyecto:

```bash
cd practica1
```

---

## 2. Configurar Supabase

El proyecto utiliza Supabase como base de datos PostgreSQL.

La estructura de migraciones se encuentra en:

```text
supabase/migrations/
```

La migración inicial es:

```text
20260930200000_initial_schema.sql
```

La migración debe ejecutarse sobre el proyecto de Supabase correspondiente.

---

## 3. Configurar Telegram

El agente utiliza un bot de Telegram creado mediante **BotFather**.

El token del bot debe configurarse como una credencial de n8n.

**El token real no debe almacen**
