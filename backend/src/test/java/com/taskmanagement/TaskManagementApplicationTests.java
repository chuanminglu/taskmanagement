package com.taskmanagement;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

@SpringBootTest
@ActiveProfiles("dev")
class TaskManagementApplicationTests {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void contextLoads() {
    }

    @Test
    void flywayMigration_fourTablesCreated() {
        List<String> tables = List.of("sys_role", "sys_user", "sys_user_role", "task");
        for (String table : tables) {
            List<Map<String, Object>> result = jdbcTemplate.queryForList(
                    "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE LOWER(TABLE_NAME) = ?",
                    table);
            assertFalse(result.isEmpty(), "表不存在: " + table);
        }
    }

    @Test
    void flywayMigration_rolesSeeded() {
        List<Map<String, Object>> roles = jdbcTemplate.queryForList("SELECT code FROM sys_role ORDER BY id");
        assertEquals(2, roles.size());
        assertEquals("ADMIN", roles.get(0).get("CODE"));
        assertEquals("MEMBER", roles.get(1).get("CODE"));
    }
}


