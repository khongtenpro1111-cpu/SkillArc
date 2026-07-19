package com.skillarc.repository;

import com.skillarc.model.Skill;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface SkillRepository extends JpaRepository<Skill, Long> {
    List<Skill> findByParentIsNull(); // Lấy các kỹ năng gốc
}
