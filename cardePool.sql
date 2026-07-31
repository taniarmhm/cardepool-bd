
DROP DATABASE IF EXISTS cardepool;

-- =========================================================
-- Base de datos: CardePool (Sistema de Carpooling Universitario)
-- =========================================================

CREATE DATABASE IF NOT EXISTS cardepool
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE cardepool;

CREATE TABLE usuarios (
    id_usuario          INT AUTO_INCREMENT PRIMARY KEY,
    nombre              VARCHAR(120) NOT NULL,
    matricula           VARCHAR(20)  NOT NULL UNIQUE,
    correo_institucional VARCHAR(150) NOT NULL UNIQUE,
    contrasena_hash     VARCHAR(255) NOT NULL,
    telefono            VARCHAR(15),
    rol                 ENUM('conductor', 'pasajero', 'admin') NOT NULL DEFAULT 'pasajero',
    verificado          BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_registro      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE vehiculos (
    id_vehiculo    INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario     INT NOT NULL,
    marca          VARCHAR(50) NOT NULL,
    modelo         VARCHAR(50) NOT NULL,
    color          VARCHAR(30),
    placas         VARCHAR(15) NOT NULL UNIQUE,
    num_asientos   TINYINT NOT NULL,
    CONSTRAINT fk_vehiculo_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE
);


CREATE TABLE viajes (
    id_viaje             INT AUTO_INCREMENT PRIMARY KEY,
    id_conductor         INT NOT NULL,
    id_vehiculo          INT NOT NULL,
    origen               VARCHAR(150) NOT NULL,
    destino              VARCHAR(150) NOT NULL,
    fecha_salida         DATE NOT NULL,
    hora_salida          TIME NOT NULL,
    asientos_disponibles TINYINT NOT NULL,
    aportacion           DECIMAL(6,2) NOT NULL DEFAULT 0,
    observaciones        VARCHAR(255),
    estado               ENUM('disponible', 'en_curso', 'finalizado', 'cancelado') NOT NULL DEFAULT 'disponible',
    pin_codigo           CHAR(6) NOT NULL,
    fecha_creacion       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_viaje_conductor
        FOREIGN KEY (id_conductor) REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_viaje_vehiculo
        FOREIGN KEY (id_vehiculo) REFERENCES vehiculos(id_vehiculo)
        ON DELETE CASCADE
);


CREATE TABLE reservas (
    id_reserva     INT AUTO_INCREMENT PRIMARY KEY,
    id_viaje       INT NOT NULL,
    id_pasajero    INT NOT NULL,
    estado         ENUM('pendiente', 'confirmada', 'cancelada') NOT NULL DEFAULT 'pendiente',
    fecha_reserva  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reserva_viaje
        FOREIGN KEY (id_viaje) REFERENCES viajes(id_viaje)
        ON DELETE CASCADE,
    CONSTRAINT fk_reserva_pasajero
        FOREIGN KEY (id_pasajero) REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT uq_reserva_unica UNIQUE (id_viaje, id_pasajero)
);


CREATE TABLE calificaciones (
    id_calificacion  INT AUTO_INCREMENT PRIMARY KEY,
    id_viaje         INT NOT NULL,
    id_calificador   INT NOT NULL,
    id_calificado    INT NOT NULL,
    puntuacion       TINYINT NOT NULL CHECK (puntuacion BETWEEN 1 AND 5),
    comentario       VARCHAR(255),
    fecha            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_calif_viaje
        FOREIGN KEY (id_viaje) REFERENCES viajes(id_viaje)
        ON DELETE CASCADE,
    CONSTRAINT fk_calif_calificador
        FOREIGN KEY (id_calificador) REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE,
    CONSTRAINT fk_calif_calificado
        FOREIGN KEY (id_calificado) REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE
);

-- ------------------------------------------- --
-- Índices de apoyo para búsquedas frecuentes  --
-- ------------------------------------------- --
CREATE INDEX idx_viajes_ruta ON viajes (origen, destino, fecha_salida);
CREATE INDEX idx_reservas_viaje ON reservas (id_viaje);
CREATE INDEX idx_vehiculos_usuario ON vehiculos (id_usuario);