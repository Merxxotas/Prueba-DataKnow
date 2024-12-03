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

-- Parte 3
-- 1. Crear la Nueva Tabla: La tabla se define con las columnas necesarias y se calcula la temperatura en Fahrenheit a partir de los datos existentes.

CREATE TABLE REGISTRO_METEOROLOGICO_DIA (
    registro_id INT AUTO_INCREMENT PRIMARY KEY,
    localidad_id INT,
    fecha DATE NOT NULL,
    temperatura_f DECIMAL(5,2),
    cobertura_id INT,
    indice_uv DECIMAL(4,2),
    presion_atmosferica DECIMAL(6,2),
    velocidad_viento DECIMAL(5,2),
    FOREIGN KEY (localidad_id) REFERENCES LOCALIDAD(localidad_id),
    FOREIGN KEY (cobertura_id) REFERENCES COBERTURA_NUBE(cobertura_id),
    UNIQUE (localidad_id, fecha)
);

-- 2. Insertar los Datos en la Nueva Tabla: Para cumplir con el requisito de agrupar por día, 
-- puedes calcular un promedio diario de la temperatura, convertirla a Fahrenheit, y trasladar los demás valores asociados.
-- La fórmula para convertir Celsius a Fahrenheit es:
-- °F=(°C×9/5)+32
-- La fórmula para convertir Celsius a Fahrenheit es:

INSERT INTO REGISTRO_METEOROLOGICO_DIA (
    localidad_id, fecha, temperatura_f, cobertura_id, indice_uv, presion_atmosferica, velocidad_viento
)
SELECT
    localidad_id,
    DATE(fecha_hora) AS fecha,
    AVG(temperatura) * 9/5 + 32 AS temperatura_f,
    MAX(cobertura_id) AS cobertura_id,
    AVG(indice_uv) AS indice_uv,
    AVG(presion_atmosferica) AS presion_atmosferica,
    AVG(velocidad_viento) AS velocidad_viento
FROM REGISTRO_METEOROLOGICO
GROUP BY localidad_id, DATE(fecha_hora);

-- 3. Verificación de los Datos y que contengan la información correcta.
SELECT * FROM REGISTRO_METEOROLOGICO_DIA;



-- Parte 4: Se necesita hacer una modificación de las tablas 'REGISTRO_METEOROLOGICO' y 'REGISTRO_METEOROLOGICO_DIA':
ALTER TABLE REGISTRO_METEOROLOGICO
ADD COLUMN delta_temperatura DECIMAL(5,2);

ALTER TABLE REGISTRO_METEOROLOGICO_DIA
ADD COLUMN delta_temperatura DECIMAL(5,2);

-- Calcular y actualizar tabla horaria en tabla 'REGISTRO_METEOROLOGICO': La diferencia de temperatura se calcula
-- comparando cada registro con el de una hora antes. Esto lo desarrollo usando una subconsulta:

UPDATE REGISTRO_METEOROLOGICO AS r
JOIN (
    SELECT 
        r1.registro_id,
        r1.temperatura - r2.temperatura AS delta_temperatura
    FROM REGISTRO_METEOROLOGICO AS r1
    LEFT JOIN REGISTRO_METEOROLOGICO AS r2
    ON r1.localidad_id = r2.localidad_id
    AND r1.fecha_hora = r2.fecha_hora + INTERVAL 1 HOUR
) AS subquery
ON r.registro_id = subquery.registro_id
SET r.delta_temperatura = subquery.delta_temperatura;

-- Actualizar la tabla en 'REGISTRO_METEOROLOGICO_DIA': A diferencia de 'REGISTRO_METEOROLOGICO', esta se calcula comparando
-- con el dia anterior. Esto lo desarrollo usando una subconsulta:

UPDATE REGISTRO_METEOROLOGICO_DIA AS d
JOIN (
    SELECT 
        d1.registro_id,
        d1.temperatura_f - d2.temperatura_f AS delta_temperatura
    FROM REGISTRO_METEOROLOGICO_DIA AS d1
    LEFT JOIN REGISTRO_METEOROLOGICO_DIA AS d2
    ON d1.localidad_id = d2.localidad_id
    AND d1.fecha = d2.fecha + INTERVAL 1 DAY
) AS subquery
ON d.registro_id = subquery.registro_id
SET d.delta_temperatura = subquery.delta_temperatura;

-- Consulta para validar los resultados:

SELECT * FROM REGISTRO_METEOROLOGICO ORDER BY localidad_id, fecha_hora;
SELECT * FROM REGISTRO_METEOROLOGICO_DIA ORDER BY localidad_id, fecha;

-- Como consideración: Para el primer registro de cada localidad, donde no hay un valor anterior, 'delta_temperatura' quedará como 'NULL'.