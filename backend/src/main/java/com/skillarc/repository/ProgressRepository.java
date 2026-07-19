package com.skillarc.repository;

import com.skillarc.model.Progress;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface ProgressRepository extends JpaRepository<Progress, Long> {
    List<Progress> findByUserId(Long userId);
    Optional<Progress> findByUserIdAndSkillId(Long userId, Long skillId);
}
