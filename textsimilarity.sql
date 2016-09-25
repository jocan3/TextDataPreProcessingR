-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 25-09-2016 a las 22:50:22
-- Versión del servidor: 10.1.16-MariaDB
-- Versión de PHP: 5.6.24

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `textsimilarity`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `algorithm`
--

CREATE TABLE `algorithm` (
  `id` int(11) NOT NULL,
  `name` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `algorithm`
--

INSERT INTO `algorithm` (`id`, `name`) VALUES
(1, 'KNN');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `dataset`
--

CREATE TABLE `dataset` (
  `id` int(11) NOT NULL,
  `name` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `dataset`
--

INSERT INTO `dataset` (`id`, `name`) VALUES
(1, 'reuters-1'),
(2, 'reuters-2'),
(3, 'candidate profiles'),
(4, 'Oil-test');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `datasetrepresentation`
--

CREATE TABLE `datasetrepresentation` (
  `id` int(11) NOT NULL,
  `dataset` int(11) NOT NULL,
  `representation` int(11) NOT NULL,
  `description` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `document`
--

CREATE TABLE `document` (
  `id` int(11) NOT NULL,
  `datasetRepresentation` int(11) NOT NULL,
  `original` longtext NOT NULL,
  `value` longtext NOT NULL,
  `class` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `experiment`
--

CREATE TABLE `experiment` (
  `id` int(11) NOT NULL,
  `datasetRepresentation` int(11) NOT NULL,
  `algorithm` int(11) NOT NULL,
  `metric` int(11) NOT NULL,
  `description` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `imputation`
--

CREATE TABLE `imputation` (
  `id` int(11) NOT NULL,
  `result` int(11) NOT NULL,
  `originalText` longtext NOT NULL,
  `expectedClass` varchar(200) NOT NULL,
  `ImputedClass` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `metric`
--

CREATE TABLE `metric` (
  `id` int(11) NOT NULL,
  `name` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `metric`
--

INSERT INTO `metric` (`id`, `name`) VALUES
(1, 'Cosine'),
(2, 'Jaccard'),
(3, 'Divergence-KL');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `representation`
--

CREATE TABLE `representation` (
  `id` int(11) NOT NULL,
  `name` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `representation`
--

INSERT INTO `representation` (`id`, `name`) VALUES
(1, 'WordsVector'),
(2, 'LDA');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `result`
--

CREATE TABLE `result` (
  `id` int(11) NOT NULL,
  `experiment` int(11) NOT NULL,
  `precision` double NOT NULL,
  `accuracy` double NOT NULL,
  `recall` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `algorithm`
--
ALTER TABLE `algorithm`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `dataset`
--
ALTER TABLE `dataset`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `datasetrepresentation`
--
ALTER TABLE `datasetrepresentation`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `document`
--
ALTER TABLE `document`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `experiment`
--
ALTER TABLE `experiment`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `imputation`
--
ALTER TABLE `imputation`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `metric`
--
ALTER TABLE `metric`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `representation`
--
ALTER TABLE `representation`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `result`
--
ALTER TABLE `result`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `algorithm`
--
ALTER TABLE `algorithm`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `dataset`
--
ALTER TABLE `dataset`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT de la tabla `datasetrepresentation`
--
ALTER TABLE `datasetrepresentation`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;
--
-- AUTO_INCREMENT de la tabla `document`
--
ALTER TABLE `document`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=213;
--
-- AUTO_INCREMENT de la tabla `experiment`
--
ALTER TABLE `experiment`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `imputation`
--
ALTER TABLE `imputation`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `metric`
--
ALTER TABLE `metric`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT de la tabla `representation`
--
ALTER TABLE `representation`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `result`
--
ALTER TABLE `result`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
