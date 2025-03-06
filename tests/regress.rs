use std::process::Command;
use glob::glob;

fn rm(p: &str) {
   if std::path::Path::new(p).is_file() {
      std::fs::remove_file(p).expect(&format!("Could not remove file: {}",p))
   }
   assert!( !std::path::Path::new(p).is_file() );
}

fn compile_bootstrap() {
   rm("bootstrap");
   let exit = Command::new("cc")
                      .stdout(std::process::Stdio::piped())
                      .stderr(std::process::Stdio::piped())
                      .arg("-o")
                      .arg("bootstrap")
                      .arg("BOOTSTRAP/cli.c")
                      .spawn()
                      .expect("failed to execute process")
                      .wait_with_output()
                      .expect("failed to wait for process");
   if !exit.status.success() {
      let stderr = String::from_utf8_lossy(&exit.stderr).to_string();
      panic!("cc error code: {}", stderr);
   };
}

fn run_bootstrap(target: &str, leave_tmp: bool) -> String {
   if !leave_tmp { rm("tmp.c"); };
   rm("a.out");
   
   let exit = Command::new("./bootstrap")
           .stdout(std::process::Stdio::piped())
           .stderr(std::process::Stdio::piped())
           .arg("--c")
           .arg("--stripdebug")
           .arg("-o")
           .arg("tmp.c")
           .arg(target)
           .spawn()
           .expect("failed to execute process")
           .wait_with_output()
           .expect("failed to wait for process");

   let mut output = "".to_string();
   if !exit.status.success() {
      output = "Error: ".to_owned() + &String::from_utf8_lossy(&exit.stdout).to_string()
                                    + &String::from_utf8_lossy(&exit.stderr).to_string();
   };
   if output=="" {
      let exit = Command::new("cc")
                      .stdout(std::process::Stdio::piped())
                      .stderr(std::process::Stdio::piped())
                      .arg("-o")
                      .arg("a.out")
                      .arg("tmp.c")
                      .spawn()
                      .expect("failed to execute process")
                      .wait_with_output()
                      .expect("failed to wait for process");
      if !exit.status.success() {
         let stderr = String::from_utf8_lossy(&exit.stderr).to_string();
         return format!("cc error code: {} on target {}", stderr, target);
      };
      let exit = Command::new("timeout")
                      .stdout(std::process::Stdio::piped())
                      .stderr(std::process::Stdio::piped())
                      .arg("30")
                      .arg("./a.out")
                      .spawn()
                      .expect("failed to execute process")
                      .wait_with_output()
                      .expect("failed to wait for process");
      output = if exit.status.success() {
         String::from_utf8_lossy(&exit.stdout).to_string()
      } else {
         "Error: ".to_owned() + &String::from_utf8_lossy(&exit.stdout).to_string()
                              + &String::from_utf8_lossy(&exit.stderr).to_string()
      };
   }
   if !leave_tmp { rm("tmp.c"); };
   rm("a.out");
   output
}

#[test]
fn regression_tests() {
   compile_bootstrap();
   let mut failures = Vec::new();
   for entry in glob("tests/regress/*.lm").unwrap() {
      let path = entry.unwrap().display().to_string();
      if !std::path::Path::new(&(path.clone() + ".skip")).exists() {
         let expected = std::fs::read_to_string(path.clone() + ".out")
                       .expect(&format!("Could not load expected output {}.out", path));
         let expected = expected.trim().to_string();
         let actual = run_bootstrap(&path, false);
         let actual = actual.trim().to_string();
         if expected != actual {
            failures.push(( "--compile", path, expected, actual ));
         }
      }
   }
   for entry in glob("tests/regress/*.lsts").unwrap() {
      let path = entry.unwrap().display().to_string();
      if !std::path::Path::new(&(path.clone() + ".skip")).exists() {
         let expected = std::fs::read_to_string(path.clone() + ".out")
                       .expect(&format!("Could not load expected output {}.out", path));
         let expected = expected.trim().to_string();
         let actual = run_bootstrap(&path, false);
         let actual = actual.trim().to_string();
         if expected != actual {
            failures.push(( "--compile", path, expected, actual ));
         }
      }
   }
   for entry in glob("tests/lib/*.lsts").unwrap() {
      let path = entry.unwrap().display().to_string();
      if !std::path::Path::new(&(path.clone() + ".skip")).exists() {
         let expected = std::fs::read_to_string(path.clone() + ".out")
                       .expect(&format!("Could not load expected output {}.out", path));
         let expected = expected.trim().to_string();
         let actual = run_bootstrap(&path, false);
         let actual = actual.trim().to_string();
         if expected != actual {
            failures.push(( "--compile", path, expected, actual ));
         }
      }
   }
   for entry in glob("tests/unit/*.lsts").unwrap() {
      let path = entry.unwrap().display().to_string();
      if !std::path::Path::new(&(path.clone() + ".skip")).exists() {
         let expected = std::fs::read_to_string(path.clone() + ".out")
                       .expect(&format!("Could not load expected output {}.out", path));
         let expected = expected.trim().to_string();
         let actual = run_bootstrap(&path, false);
         let actual = actual.trim().to_string();
         if expected != actual {
            failures.push(( "--compile", path, expected, actual ));
         }
      }
   }
   for entry in glob("tests/c/*.c").unwrap() {
      let path = entry.unwrap().display().to_string();
      if !std::path::Path::new(&(path.clone() + ".skip")).exists() {
         let expected = std::fs::read_to_string(path.clone() + ".out")
                       .expect(&format!("Could not load expected output {}.out", path));
         let expected = expected.trim().to_string();
         let actual = run_bootstrap(&path, true);
         let actual = actual.trim().to_string();
         if actual.starts_with("Error:") {
            failures.push(( "--compile", path, expected, actual ));
         } else {
            let mut original_c = std::fs::read_to_string(path.clone())
                          .expect(&format!("Could not load expected output {}", path));
            if expected.len() > 0 { original_c = expected; };
            let result_c = std::fs::read_to_string("tmp.c")
                          .expect(&format!("Could not load expected output tmp.c during {}", path));
            let o1 = original_c.chars().filter(|c| !c.is_whitespace()).collect();
            let r1 = result_c.chars().filter(|c| !c.is_whitespace()).collect();
            if o1 != r1 {
               failures.push(( "--compile", path, o1, r1 ));
            };
         }
      }
   }
   for (mode,path,expected,actual) in &failures {
      eprintln!("TEST {} {}", mode, path);
      eprintln!("Expected: '{}'", &expected[..std::cmp::min(4000,expected.len())] );
      eprintln!("Actual: '{}'", &actual[..std::cmp::min(4000,actual.len())] );
   }
   assert_eq!( failures.len(), 0 );
}
