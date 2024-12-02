-- Creación de tablas
CREATE TABLE PAIS (
    pais_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE CIUDAD (
    ciudad_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    pais_id INT,
    FOREIGN KEY (pais_id) REFERENCES PAIS(pais_id)
);

CREATE TABLE LOCALIDAD (
    localidad_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    ciudad_id INT,
    FOREIGN KEY (ciudad_id) REFERENCES CIUDAD(ciudad_id)
);

CREATE TABLE COBERTURA_NUBE (
    cobertura_id INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL
);

CREATE TABLE REGISTRO_METEOROLOGICO (
    registro_id INT AUTO_INCREMENT PRIMARY KEY,
    localidad_id INT,
    fecha_hora DATETIME NOT NULL,
    temperatura DECIMAL(5,2),
    cobertura_id INT,
    indice_uv DECIMAL(4,2),
    presion_atmosferica DECIMAL(6,2),
    velocidad_viento DECIMAL(5,2),
    FOREIGN KEY (localidad_id) REFERENCES LOCALIDAD(localidad_id),
    FOREIGN KEY (cobertura_id) REFERENCES COBERTURA_NUBE(cobertura_id),
    UNIQUE (localidad_id, fecha_hora)
);

-- Datos de ejemplo
INSERT INTO PAIS (nombre) VALUES ('Colombia');

INSERT INTO CIUDAD (nombre, pais_id) VALUES 
('Medellín', 1),
('Envigado', 1),
('Sabaneta', 1);

INSERT INTO LOCALIDAD (nombre, ciudad_id) VALUES
('Poblado', 1),
('Laureles', 1),
('Zona Centro', 2),
('Las Vegas', 2),
('Mayorca', 3);

INSERT INTO COBERTURA_NUBE (descripcion) VALUES 
('Mínima'),
('Parcial'),
('Total');

INSERT INTO REGISTRO_METEOROLOGICO (
    localidad_id, fecha_hora, temperatura, cobertura_id, 
    indice_uv, presion_atmosferica, velocidad_viento
) VALUES 
(1, '2024-12-02 14:00:00', 23.5, 2, 8.5, 1013.25, 10.5),
(2, '2024-12-02 14:00:00', 24.0, 1, 9.0, 1012.80, 8.2),
(3, '2024-12-02 14:00:00', 22.8, 3, 7.5, 1013.50, 12.0);