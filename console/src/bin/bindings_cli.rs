use std::fs::File;
#[allow(unused_imports)] use std::io::Read;
use std::io::Error as IoError;
use clap::{App, AppSettings, Arg, ArgMatches};
use failure::Error;
use console::CliError;

#[derive(Debug, Fail)]
#[fail(display = "Errors that occur while generating bindings")]
enum BindingError {
    /// Indicates that an io::Error occurred involving a given file.
    /// _0: The name of the file involved.
    /// _1: The io::Error with details.
    #[fail(display = "File error for '{}': {}", _0, _1)]
    FileError(String, IoError),
}

pub fn make_subcommand<'a, 'b>() -> App<'a, 'b> {
    App::new("binding")
        .settings(&[
            AppSettings::AllowExternalSubcommands,
            AppSettings::ArgRequiredElseHelp,
            AppSettings::DeriveDisplayOrder,
            AppSettings::ColoredHelp,
        ])
        .template(
            "{bin} \n\
             USAGE: \n    {usage} \n\n\
             {all-args}"
        )
        .subcommands(vec![
            generate::make_subcommand(),
        ])
}

pub fn execute(args: &ArgMatches) -> Result<(), Error> {
    match args.subcommand() {
        ("generate", Some(m)) => generate::execute(m),
        (unknown, _) => Err(CliError::UnrecognizedCommand(unknown.to_owned()).into()),
    }
}

/// Usage: `flipper generate [LANG]`, where `[LANG]` is one of:
///        --java, --javascript, --python, --objc, --swift, --rust
/// Flipper modules can be executed remotely from a host machine
/// such as a laptop or mobile phone.
pub mod generate {
    use super::*;
    use console::bindings;

    pub fn make_subcommand<'a, 'b>() -> App<'a, 'b> {
        App::new("generate")
            .alias("gen")
            .about("Generate Flipper language bindings")
            .before_help("Generate bindings for the specified module")
            .arg(Arg::with_name("file")
                .index(1)
                .takes_value(true)
                .required(true)
                .help("The module file to generate language bindings for"))
            .arg(Arg::with_name("name")
                .index(2)
                .takes_value(true)
                .required(true)
                .help("The name of the module"))
    }

    pub fn execute(args: &ArgMatches) -> Result<(), Error> {
        // Guaranteed to be safe because these are required arguments.
        let filename = args.value_of("file").unwrap();
        let module_name = args.value_of("name").unwrap();

        let mut file = File::open(filename)
            .map_err(|e| BindingError::FileError(filename.to_owned(), e))?;

        let module_binary = {
            let mut v = Vec::new();
            let _ = file.read_to_end(&mut v);
            v
        };

        let mut out = File::create("./binding.c")
            .map_err(|e| BindingError::FileError("binding.c".to_owned(), e))?;

        let module = bindings::Module::parse(String::from(module_name), "".to_owned(), &module_binary)?;
        bindings::generators::c::generate_module(module, &mut out)
    }
}
