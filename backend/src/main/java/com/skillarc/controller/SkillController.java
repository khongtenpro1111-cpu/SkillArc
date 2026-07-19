package com.skillarc.controller;

import com.skillarc.model.Progress;
import com.skillarc.model.Skill;
import com.skillarc.repository.ProgressRepository;
import com.skillarc.repository.SkillRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class SkillController {

    @Autowired
    private SkillRepository skillRepository;

    @Autowired
    private ProgressRepository progressRepository;

    // Lấy toàn bộ cây kỹ năng (bắt đầu từ các kỹ năng gốc)
    @GetMapping("/skills")
    public List<Skill> getSkills() {
        return skillRepository.findByParentIsNull();
    }

    // Lấy tiến độ của một người dùng (Trong thực tế nên lấy từ Token JWT)
    @GetMapping("/progress")
    public ResponseEntity<List<Progress>> getUserProgress(@RequestParam(required = false) Long userId) {
        // Nếu không truyền userId, có thể lấy mặc định là 1 cho mục đích demo
        Long id = (userId != null) ? userId : 1L;
        return ResponseEntity.ok(progressRepository.findByUserId(id));
    }

    // Cập nhật tiến độ kỹ năng
    @PostMapping("/progress/update")
    public ResponseEntity<?> updateProgress(@RequestBody Map<String, Object> data) {
        Long userId = Long.valueOf(data.get("userId").toString());
        Long skillId = Long.valueOf(data.get("skillId").toString());
        double percentage = Double.parseDouble(data.get("completionPercentage").toString());
        boolean completed = (boolean) data.get("isCompleted");

        Optional<Progress> progressOpt = progressRepository.findByUserIdAndSkillId(userId, skillId);
        Progress progress;
        
        if (progressOpt.isPresent()) {
            progress = progressOpt.get();
        } else {
            progress = new Progress();
            progress.setUserId(userId);
            progress.setSkillId(skillId);
        }

        progress.setCompletionPercentage(percentage);
        progress.setCompleted(completed);
        
        return ResponseEntity.ok(progressRepository.save(progress));
    }
}
