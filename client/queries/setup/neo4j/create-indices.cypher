
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

CREATE CONSTRAINT FOR (n:City)         REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT FOR (n:Comment)      REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT FOR (n:Country)      REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT FOR (n:Forum)        REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT FOR (n:Message)      REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT FOR (n:Organisation) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT FOR (n:Person)       REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT FOR (n:Post)         REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT FOR (n:Tag)          REQUIRE n.id IS UNIQUE;