--
-- PostgreSQL database dump
--

\restrict mUqRQcTKmXyb4klU4Zzz9xlgpo7ZbrpM0gG8kfbfUJGxDX1e2iexeLlrYid7wT5

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: service; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.service (
    name character varying(100) NOT NULL,
    base_price integer NOT NULL,
    lead_time integer NOT NULL,
    CONSTRAINT service_base_price_check CHECK ((base_price > 0)),
    CONSTRAINT service_lead_time_check CHECK ((lead_time > 0))
);


ALTER TABLE public.service OWNER TO postgres;

--
-- Data for Name: service; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.service (name, base_price, lead_time) FROM stdin;
Замена кресел	200000	3
Замена колодок	320000	5
Замена масла	60500	1
Замена фильтров	36300	1
Замена тормозных колодок	96800	2
Замена свечей зажигания	30250	1
Замена аккумулятора	18150	1
Шиномонтаж	48400	2
Развал-схождение	72600	2
Диагностика двигателя	42350	1
Замена ламп	12100	1
Полное ТО	145200	3
\.


--
-- Name: service service_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service
    ADD CONSTRAINT service_pkey PRIMARY KEY (name);


--
-- Name: TABLE service; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.service TO watcher;
GRANT DELETE ON TABLE public.service TO killer;


--
-- PostgreSQL database dump complete
--

\unrestrict mUqRQcTKmXyb4klU4Zzz9xlgpo7ZbrpM0gG8kfbfUJGxDX1e2iexeLlrYid7wT5

