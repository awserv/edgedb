#
# This source file is part of the EdgeDB open source project.
#
# Copyright 2018-present MagicStack Inc. and the EdgeDB authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


CREATE MODULE sys;


CREATE TYPE sys::Database {
    CREATE REQUIRED PROPERTY name -> std::str {
        SET readonly := True;
    };
};


CREATE TYPE sys::Role {
    CREATE REQUIRED PROPERTY name -> std::str {
        CREATE CONSTRAINT std::exclusive;
    };

    CREATE REQUIRED PROPERTY allow_login -> std::bool;
    CREATE REQUIRED PROPERTY is_superuser -> std::bool;
    CREATE PROPERTY password -> std::str;
};


ALTER TYPE sys::Role {
    CREATE MULTI LINK member_of -> sys::Role;
};


CREATE FUNCTION
sys::sleep(duration: std::float64) -> std::bool
{
    FROM SQL $$
    SELECT pg_sleep("duration") IS NOT NULL;
    $$;
};


CREATE FUNCTION
sys::sleep(duration: std::timedelta) -> std::bool
{
    FROM SQL $$
    SELECT pg_sleep_for("duration") IS NOT NULL;
    $$;
};


CREATE FUNCTION
sys::advisory_lock(key: std::int64) -> std::bool
{
    FROM SQL $$
    SELECT CASE WHEN "key" < 0 THEN
        edgedb._raise_exception('lock key cannot be negative', NULL::bool)
    ELSE
        pg_advisory_lock("key") IS NOT NULL
    END;
    $$;
};


CREATE FUNCTION
sys::advisory_unlock(key: std::int64) -> std::bool
{
    FROM SQL $$
    SELECT CASE WHEN "key" < 0 THEN
        edgedb._raise_exception('lock key cannot be negative', NULL::bool)
    ELSE
        pg_advisory_unlock("key")
    END;
    $$;
};


CREATE FUNCTION
sys::advisory_unlock_all() -> std::bool
{
    FROM SQL $$
    SELECT pg_advisory_unlock_all() IS NOT NULL;
    $$;
};