
-- BOA Flight Management System Schema (Supabase / PostgreSQL)

-- USERS PROFILE TABLE (linked with supabase auth.users)
create table public.users_profile (
    id uuid primary key references auth.users(id) on delete cascade,
    nombre text not null,
    apellido text not null,
    telefono text,
    fecha_nacimiento date,
    genero text check (genero in ('masculino','femenino')),
    tipo_documento text check (tipo_documento in ('pasaporte','documento_identidad')),
    numero_documento text,
    created_at timestamp with time zone default now()
);

-- FLIGHTS TABLE
create table public.flights (
    id uuid primary key default gen_random_uuid(),
    origen text not null,
    destino text not null,
    fecha_salida timestamp with time zone not null,
    fecha_llegada timestamp with time zone not null,
    precio numeric not null,
    asientos_totales integer not null,
    asientos_disponibles integer not null,
    estado text check (estado in (
        'programado',
        'abordando',
        'en_vuelo',
        'aterrizado',
        'cancelado'
    )) default 'programado',
    created_at timestamp with time zone default now()
);

-- RESERVATIONS TABLE
create table public.reservations (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users(id),
    flight_id uuid references flights(id),
    estado text check (estado in (
        'pendiente',
        'pago_en_revision',
        'confirmado',
        'cancelado',
        'completado'
    )) default 'pendiente',
    precio_total numeric,
    created_at timestamp with time zone default now()
);

-- PASSENGERS TABLE
create table public.passengers (
    id uuid primary key default gen_random_uuid(),
    reservation_id uuid references reservations(id) on delete cascade,
    nombre text not null,
    apellido text not null,
    fecha_nacimiento date,
    genero text check (genero in ('masculino','femenino')),
    tipo_documento text check (tipo_documento in ('pasaporte','documento_identidad')),
    numero_documento text,
    correo text,
    celular text,
    created_at timestamp with time zone default now()
);

-- SPECIAL ASSISTANCE TABLE
create table public.special_assistance (
    id uuid primary key default gen_random_uuid(),
    passenger_id uuid references passengers(id) on delete cascade,
    discapacidad_auditiva boolean default false,
    movilidad_reducida boolean default false,
    asistencia_aeropuerto boolean default false,
    discapacidad_visual boolean default false
);

-- PAYMENTS TABLE
create table public.payments (
    id uuid primary key default gen_random_uuid(),
    reservation_id uuid references reservations(id),
    monto numeric not null,
    metodo text,
    comprobante_url text,
    estado text check (estado in (
        'pendiente',
        'revisando',
        'aprobado',
        'rechazado'
    )) default 'pendiente',
    fecha timestamp with time zone default now()
);

-- INDEXES
create index idx_flights_origen on flights(origen);
create index idx_flights_destino on flights(destino);
create index idx_reservations_user on reservations(user_id);
create index idx_passengers_reservation on passengers(reservation_id);

-- ENABLE ROW LEVEL SECURITY
alter table users_profile enable row level security;
alter table reservations enable row level security;
alter table passengers enable row level security;
alter table payments enable row level security;

-- BASIC RLS POLICY (users can see their own data)
create policy "Users can view own profile"
on users_profile
for select
using (auth.uid() = id);

create policy "Users manage their reservations"
on reservations
for all
using (auth.uid() = user_id);

create policy "Users view their passengers"
on passengers
for select
using (
    reservation_id in (
        select id from reservations where user_id = auth.uid()
    )
);
