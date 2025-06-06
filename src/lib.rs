pub mod app;
pub mod cli;
pub mod test;
pub mod ui;

#[cfg(test)]
mod tests {
    use super::*;
    use std::time::Duration;

    #[test]
    fn test_app_history_management() {
        let config = test::TestConfig {
            tests: vec![],
            build: None,
        };
        let initial_results = vec![];

        let mut app = app::App::new(initial_results, config);

        // Test history limit
        for i in 0..150 {
            let test_result = test::TestResult {
                name: format!("test_{}", i),
                success: true,
                actual_output: "output".to_string(),
                diff: None,
                command: "echo".to_string(),
                args: vec![],
                input: None,
                execution_time: Duration::from_millis(100),
                is_release: false,
                build_commands: None,
            };
            app.test_results = vec![test_result];
            app.add_to_history();
        }

        // History should be limited to MAX_HISTORY_ENTRIES
        assert!(app.history.len() <= app::App::MAX_HISTORY_ENTRIES);
        assert!(
            app.history.len() > app::App::MAX_HISTORY_ENTRIES - app::App::HISTORY_CLEANUP_BATCH
        );
    }

    #[test]
    fn test_config_loading() {
        use std::fs;
        use tempfile::TempDir;

        let temp_dir = TempDir::new().unwrap();
        let toml_path = temp_dir.path().join("test.toml");

        let toml_content = r#"
[[tests]]
name = "Echo Test"
command = "echo"
args = ["Hello"]
expected_output = "Hello"
timeout_secs = 5

[build]
release = false
"#;

        fs::write(&toml_path, toml_content).unwrap();

        let config = test::load_config(&toml_path).unwrap();
        assert_eq!(config.tests.len(), 1);
        assert_eq!(config.tests[0].name, "Echo Test");
        assert_eq!(config.tests[0].command, "echo");
        assert_eq!(config.build.as_ref().unwrap().release, false);
    }

    #[test]
    fn test_template_processing() {
        let template = "cargo build {{#if release}}--release{{/if}}";

        // This is testing internal function, we need to make it public for testing
        // For now, this is a placeholder for the template processing test
        let release_result = test::process_template(template, true);
        let debug_result = test::process_template(template, false);

        assert!(release_result.contains("--release"));
        assert!(!debug_result.contains("--release"));
    }

    #[test]
    fn test_async_command_execution() {
        let result = test::execute_command_sync(
            "echo",
            &["hello".to_string()],
            None,
            Duration::from_secs(5),
        );

        assert!(result.is_ok());
        let (output, success, _duration) = result.unwrap();
        assert!(success);
        assert_eq!(output.trim(), "hello");
    }

    #[test]
    fn test_app_navigation() {
        let config = test::TestConfig {
            tests: vec![],
            build: None,
        };
        let test_results = vec![
            test::TestResult {
                name: "test1".to_string(),
                success: true,
                actual_output: "output1".to_string(),
                diff: None,
                command: "echo".to_string(),
                args: vec![],
                input: None,
                execution_time: Duration::from_millis(100),
                is_release: false,
                build_commands: None,
            },
            test::TestResult {
                name: "test2".to_string(),
                success: false,
                actual_output: "output2".to_string(),
                diff: None,
                command: "echo".to_string(),
                args: vec![],
                input: None,
                execution_time: Duration::from_millis(200),
                is_release: false,
                build_commands: None,
            },
        ];

        let mut app = app::App::new(test_results, config);

        // Test navigation
        assert_eq!(app.selected_test, 0);
        app.next();
        assert_eq!(app.selected_test, 1);
        app.next();
        assert_eq!(app.selected_test, 0); // Should wrap around

        app.previous();
        assert_eq!(app.selected_test, 1);

        // Test tab navigation
        assert_eq!(app.tab_index, 0);
        app.next_tab();
        assert_eq!(app.tab_index, 1);
        app.previous_tab();
        assert_eq!(app.tab_index, 0);

        // Test statistics
        let (passed, total, pass_rate) = app.get_stats();
        assert_eq!(passed, 1);
        assert_eq!(total, 2);
        assert_eq!(pass_rate, 50.0);
    }
}
