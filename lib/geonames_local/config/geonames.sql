--
-- PostgreSQL database dump
--

-- Started on 2010-03-19 05:44:38 BRT

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 2245 (class 1259 OID 21665)
-- Dependencies: 2544 2545 2546 3 992
-- Name: cities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cities (
    id integer NOT NULL,
    country_id integer NOT NULL,
    province_id integer,
    name character varying(255) NOT NULL,
    gid integer,
    zip integer,
    geom geometry,
    CONSTRAINT enforce_dims_geom CHECK ((st_ndims(geom) = 2)),
    CONSTRAINT enforce_geotype_geom CHECK (((geometrytype(geom) = 'POINT'::text) OR (geom IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((st_srid(geom) = 4326))
);


--
-- TOC entry 2244 (class 1259 OID 21663)
-- Dependencies: 3 2245
-- Name: cities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2557 (class 0 OID 0)
-- Dependencies: 2244
-- Name: cities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cities_id_seq OWNED BY cities.id;


--
-- TOC entry 2543 (class 2604 OID 21668)
-- Dependencies: 2245 2244 2245
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE cities ALTER COLUMN id SET DEFAULT nextval('cities_id_seq'::regclass);


--
-- TOC entry 2548 (class 2606 OID 21670)
-- Dependencies: 2245 2245
-- Name: cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- TOC entry 2549 (class 1259 OID 21697)
-- Dependencies: 2245
-- Name: index_cities_on_country_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cities_on_country_id ON cities USING btree (country_id);


--
-- TOC entry 2550 (class 1259 OID 21699)
-- Dependencies: 2245 1869
-- Name: index_cities_on_geom; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cities_on_geom ON cities USING gist (geom);


--
-- TOC entry 2551 (class 1259 OID 21695)
-- Dependencies: 2245
-- Name: index_cities_on_gid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cities_on_gid ON cities USING btree (gid);


--
-- TOC entry 2552 (class 1259 OID 21694)
-- Dependencies: 2245
-- Name: index_cities_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cities_on_name ON cities USING btree (name);


--
-- TOC entry 2553 (class 1259 OID 21698)
-- Dependencies: 2245
-- Name: index_cities_on_province_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cities_on_province_id ON cities USING btree (province_id);


--
-- TOC entry 2554 (class 1259 OID 21696)
-- Dependencies: 2245
-- Name: index_cities_on_zip; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cities_on_zip ON cities USING btree (zip);


--
-- PostgreSQL database dump
--

-- Started on 2010-03-19 05:45:05 BRT

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 2249 (class 1259 OID 21688)
-- Dependencies: 3
-- Name: countries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE countries (
    id integer NOT NULL,
    name character varying(30) NOT NULL,
    abbr character varying(2) NOT NULL
);


--
-- TOC entry 2248 (class 1259 OID 21686)
-- Dependencies: 3 2249
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2548 (class 0 OID 0)
-- Dependencies: 2248
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE countries_id_seq OWNED BY countries.id;


--
-- TOC entry 2543 (class 2604 OID 21691)
-- Dependencies: 2249 2248 2249
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE countries ALTER COLUMN id SET DEFAULT nextval('countries_id_seq'::regclass);


--
-- TOC entry 2545 (class 2606 OID 21693)
-- Dependencies: 2249 2249
-- Name: countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump
--

-- Started on 2010-03-19 05:45:19 BRT

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 2247 (class 1259 OID 21680)
-- Dependencies: 3
-- Name: provinces; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE provinces (
    id integer NOT NULL,
    country_id integer NOT NULL,
    name character varying(255) NOT NULL,
    abbr character varying(2) NOT NULL,
    gid integer
);


--
-- TOC entry 2246 (class 1259 OID 21678)
-- Dependencies: 3 2247
-- Name: provinces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE provinces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 2552 (class 0 OID 0)
-- Dependencies: 2246
-- Name: provinces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE provinces_id_seq OWNED BY provinces.id;


--
-- TOC entry 2543 (class 2604 OID 21683)
-- Dependencies: 2246 2247 2247
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE provinces ALTER COLUMN id SET DEFAULT nextval('provinces_id_seq'::regclass);


--
-- TOC entry 2549 (class 2606 OID 21685)
-- Dependencies: 2247 2247
-- Name: provinces_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY provinces
    ADD CONSTRAINT provinces_pkey PRIMARY KEY (id);


--
-- TOC entry 2544 (class 1259 OID 21701)
-- Dependencies: 2247
-- Name: index_provinces_on_abbr; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_provinces_on_abbr ON provinces USING btree (abbr);


--
-- TOC entry 2545 (class 1259 OID 21703)
-- Dependencies: 2247
-- Name: index_provinces_on_country_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_provinces_on_country_id ON provinces USING btree (country_id);


--
-- TOC entry 2546 (class 1259 OID 21702)
-- Dependencies: 2247
-- Name: index_provinces_on_gid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_provinces_on_gid ON provinces USING btree (gid);


--
-- TOC entry 2547 (class 1259 OID 21700)
-- Dependencies: 2247
-- Name: index_provinces_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_provinces_on_name ON provinces USING btree (name);


-- Completed on 2010-03-19 05:45:19 BRT

--
-- PostgreSQL database dump complete
--





