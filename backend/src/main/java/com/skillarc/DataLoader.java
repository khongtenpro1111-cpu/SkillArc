package com.skillarc;

import com.skillarc.model.Skill;
import com.skillarc.repository.SkillRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.Arrays;

@Component
public class DataLoader implements CommandLineRunner {

    @Autowired
    private SkillRepository skillRepository;

    @Override
    public void run(String... args) throws Exception {
        if (skillRepository.count() == 0) {
            // Tạo kỹ năng gốc: Mobile Development
            Skill mobile = new Skill();
            mobile.setTitle("Mobile Development");
            mobile.setDescription("Xây dựng ứng dụng di động đa nền tảng");
            mobile.setCategory("Mobile");
            mobile.setLevel(1);
            skillRepository.save(mobile);

            // Tạo kỹ năng con: Flutter
            Skill flutter = new Skill();
            flutter.setTitle("Flutter");
            flutter.setDescription("Học framework Flutter và Dart");
            flutter.setCategory("Mobile");
            flutter.setLevel(2);
            flutter.setParent(mobile);
            skillRepository.save(flutter);

            // Tạo kỹ năng gốc: Backend Development
            Skill backend = new Skill();
            backend.setTitle("Backend Development");
            backend.setDescription("Xây dựng hệ thống máy chủ và API");
            backend.setCategory("Backend");
            backend.setLevel(1);
            skillRepository.save(backend);

            // Tạo kỹ năng con: Spring Boot
            Skill springBoot = new Skill();
            springBoot.setTitle("Spring Boot");
            springBoot.setDescription("Lập trình Java Backend chuyên nghiệp");
            springBoot.setCategory("Backend");
            springBoot.setLevel(2);
            springBoot.setParent(backend);
            skillRepository.save(springBoot);

            System.out.println(">>> Đã nạp dữ liệu kỹ năng mẫu vào Database!");
        }
    }
}
