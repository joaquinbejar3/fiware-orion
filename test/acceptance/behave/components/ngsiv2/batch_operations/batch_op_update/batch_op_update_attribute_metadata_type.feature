# -*- coding: utf-8 -*-

# Copyright 2016 Telefonica Investigacion y Desarrollo, S.A.U
#
# This file is part of Orion Context Broker.
#
# Orion Context Broker is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Orion Context Broker is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero
# General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Orion Context Broker. If not, see http://www.gnu.org/licenses/.
#
# For those usages not covered by this license please contact with
# iot_support at tid dot es
#
# author: 'Iván Arias León (ivan dot ariasleon at telefonica dot com)'

#
#  Note: the "skip" tag is to skip the scenarios that still are not developed or failed
#        -tg=-skip
#


Feature: Attribute metadata type in update Batch operation using NGSI v2. "POST" - /v2/op/update plus payload and queries parameters
  As a context broker user
  I would like to  create entities requests using NGSI v2
  So that I can manage and use them in my scripts

  Actions Before the Feature:
  Setup: update properties test file from "epg_contextBroker.txt" and sudo local "false"
  Setup: update contextBroker config file
  Setup: start ContextBroker
  Check: verify contextBroker is installed successfully
  Check: verify mongo is installed successfully

  Actions After each Scenario:
  Setup: delete database in mongo

  Actions After the Feature:
  Setup: stop ContextBroker

  #  --------------------- attribute metadata type ---------------------------

  @attribute_metadata_type_without
  Scenario:  update entities with update batch operations using NGSI v2 without attributes metadata types
    Given  a definition of headers
      | parameter          | value                              |
      | Fiware-Service     | test_op_update_attribute_meta_type |
      | Fiware-ServicePath | /test                              |
      | Content-Type       | application/json                   |
    # These properties below are used in update beh batch operation request
    And define a entity properties to update in a single batch operation
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room1       |
      | attributes_name  | temperature |
      | attributes_value | 34          |
      | metadatas_name   | warning     |
      | metadatas_value  | hot         |
    When update entities in a single batch operation "APPEND"
    Then verify that receive a "No Content" http code
    And verify that entities are stored in mongo

  @attribute_metadata_type
  Scenario Outline:  update entities with update batch operations using NGSI v2 with several attribute metadata types
    Given  a definition of headers
      | parameter          | value                              |
      | Fiware-Service     | test_op_update_attribute_meta_type |
      | Fiware-ServicePath | /test                              |
      | Content-Type       | application/json                   |
    # These properties below are used in update beh batch operation request
    And define a entity properties to update in a single batch operation
      | parameter        | value                  |
      | entities_type    | house                  |
      | entities_id      | room1                  |
      | attributes_name  | temperature            |
      | attributes_type  | celsius                |
      | attributes_value | 34                     |
      | metadatas_name   | warning                |
      | metadatas_value  | hot                    |
      | metadatas_type   | <attributes_meta_type> |
    When update entities in a single batch operation "APPEND"
    Then verify that receive a "No Content" http code
    And verify that entities are stored in mongo
    Examples:
      | attributes_meta_type |
      | alarm                |
      | 34                   |
      | false                |
      | true                 |
      | 34.4E-34             |
      | temp.34              |
      | temp_34              |
      | temp-34              |
      | TEMP34               |
      | house_flat           |
      | house.flat           |
      | house-flat           |
      | house@flat           |
      | random=10            |
      | random=100           |
      | random=256           |

  @attribute_metadata_type_not_plain_ascii @BUG_2674
  Scenario Outline:  try to update entities with update batch operations using NGSI v2 with with not plain ascii in attribute metadata types
    Given  a definition of headers
      | parameter          | value                                    |
      | Fiware-Service     | test_op_update_attribute_meta_type_error |
      | Fiware-ServicePath | /test                                    |
      | Content-Type       | application/json                         |
    # These properties below are used in update beh batch operation request
    And define a entity properties to update in a single batch operation
      | parameter        | value                  |
      | entities_type    | house                  |
      | entities_id      | room1                  |
      | attributes_name  | temperature            |
      | attributes_type  | celsius                |
      | attributes_value | 34                     |
      | metadatas_name   | warning                |
      | metadatas_value  | hot                    |
      | metadatas_type   | <attributes_meta_type> |
    When update entities in a single batch operation "APPEND"
    Then verify that receive a "Bad Request" http code
    And verify an error response
      | parameter   | value                               |
      | error       | BadRequest                          |
      | description | Invalid characters in metadata type |
    Examples:
      | attributes_meta_type |
      | habitación           |
      | españa               |
      | barça                |
      | my house             |

  @attribute_metadata_type_max_length @BUG_2676
  Scenario:  try to update entities with update batch operations using NGSI v2 with an attributes metadata type that exceeds the maximum allowed (256)
    Given  a definition of headers
      | parameter          | value                                    |
      | Fiware-Service     | test_op_update_attribute_meta_type_error |
      | Fiware-ServicePath | /test                                    |
      | Content-Type       | application/json                         |
    # These properties below are used in update beh batch operation request
    And define a entity properties to update in a single batch operation
      | parameter        | value       |
      | entities_type    | house       |
      | entities_id      | room1       |
      | attributes_name  | temperature |
      | attributes_type  | celsius     |
      | attributes_value | 34          |
      | metadatas_name   | warning     |
      | metadatas_value  | hot         |
      | metadatas_type   | random=257  |
    When update entities in a single batch operation "APPEND"
    Then verify that receive a "Bad Request" http code
    And verify an error response
      | parameter   | value                                                |
      | error       | BadRequest                                           |
      | description | metadata type length: 257, max length supported: 256 |

  @attribute_metadata_type_length_zero @BUG_2676
  Scenario:  try to update entities with update batch operations using NGSI v2 with length zero in the attributes metadata type
    Given  a definition of headers
      | parameter          | value                                    |
      | Fiware-Service     | test_op_update_attribute_meta_type_error |
      | Fiware-ServicePath | /test                                    |
      | Content-Type       | application/json                         |
     # These properties below are used in update beh batch operation request
    And define a entity properties to update in a single batch operation
      | parameter        | value         |
      | entities_type    | "house"       |
      | entities_id      | "room1"       |
      | attributes_name  | "temperature" |
      | attributes_type  | "celsius"     |
      | attributes_value | 34            |
      | metadatas_name   | "warning"     |
      | metadatas_value  | "hot"         |
      | metadatas_type   | ""            |
    When update entities in a single batch operation "'APPEND'" in raw mode
    Then verify that receive a "Bad Request" http code
    And verify an error response
      | parameter   | value                                            |
      | error       | BadRequest                                       |
      | description | metadata type length: 0, min length supported: 1 |

  @attribute_metadata_type_wrong @BUG_2676
  Scenario Outline:  try to update entities with update batch operations using NGSI v2 with wrong attributes metadata types
    Given  a definition of headers
      | parameter          | value                                    |
      | Fiware-Service     | test_op_update_attribute_meta_type_error |
      | Fiware-ServicePath | /test                                    |
      | Content-Type       | application/json                         |
    # These properties below are used in update beh batch operation request
    And define a entity properties to update in a single batch operation
      | parameter        | value                  |
      | entities_type    | house                  |
      | entities_id      | room1                  |
      | attributes_name  | temperature            |
      | attributes_type  | celsius                |
      | attributes_value | 34                     |
      | metadatas_name   | warning                |
      | metadatas_value  | hot                    |
      | metadatas_type   | <attributes_meta_type> |
    When update entities in a single batch operation "APPEND"
    Then verify that receive a "Bad Request" http code
    And verify an error response
      | parameter   | value                               |
      | error       | BadRequest                          |
      | description | Invalid characters in metadata type |
    And verify that entities are not stored in mongo
    Examples:
      | attributes_meta_type |
      | house<flat>          |
      | house=flat           |
      | house"flat"          |
      | house'flat'          |
      | house;flat           |
      | house(flat)          |
      | house_?              |
      | house_&              |
      | house_/              |
      | house_#              |

  @attribute_metadata_type_no_string
  Scenario Outline:  try to update entities with update batch operations using NGSI v2 with wrong type (no string) in attributes metadata type (integer, boolean, objects, etc)
    Given  a definition of headers
      | parameter          | value                                    |
      | Fiware-Service     | test_op_update_attribute_meta_type_error |
      | Fiware-ServicePath | /test                                    |
      | Content-Type       | application/json                         |
     # These properties below are used in update beh batch operation request
    And define a entity properties to update in a single batch operation
      | parameter        | value                  |
      | entities_type    | "house"                |
      | entities_id      | "room1"                |
      | attributes_name  | "temperature"          |
      | attributes_type  | "celsius"              |
      | attributes_value | 34                     |
      | metadatas_name   | "warning"              |
      | metadatas_value  | "hot"                  |
      | metadatas_type   | <attributes_meta_type> |
    When update entities in a single batch operation "'APPEND'" in raw mode
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                |
      | error       | ParseError                           |
      | description | Errors found in incoming JSON buffer |
    Examples:
      | attributes_meta_type |
      | rewrewr              |
      | SDFSDFSDF            |

  @attribute_metadata_type_invalid_type
  Scenario Outline:  try to update entities with update batch operations using NGSI v2 with wrong type (no string) in attributes metadata type (integer, boolean, objects, etc)
    Given  a definition of headers
      | parameter          | value                                    |
      | Fiware-Service     | test_op_update_attribute_meta_type_error |
      | Fiware-ServicePath | /test                                    |
      | Content-Type       | application/json                         |
     # These properties below are used in update beh batch operation request
    And define a entity properties to update in a single batch operation
      | parameter        | value                  |
      | entities_type    | "house"                |
      | entities_id      | "room1"                |
      | attributes_name  | "temperature"          |
      | attributes_type  | "celsius"              |
      | attributes_value | 34                     |
      | metadatas_name   | "warning"              |
      | metadatas_value  | "hot"                  |
      | metadatas_type   | <attributes_meta_type> |
    When update entities in a single batch operation "'APPEND'" in raw mode
    Then verify that receive an "Bad Request" http code
    And verify an error response
      | parameter   | value                                         |
      | error       | BadRequest                                    |
      | description | invalid JSON type for attribute metadata type |
    Examples:
      | attributes_meta_type |
      | false                |
      | true                 |
      | 34                   |
      | {"a":34}             |
      | ["34", "a", 45]      |
      | null                 |
