use clap::Parser;
use serde::Deserialize;

#[derive(Parser, Debug, Clone, Deserialize)]
#[clap(author, version, about, long_about = None)]
pub struct Opt {
    /// Listen host
    #[clap(long, default_value = "0.0.0.0")]
    pub host: String,
    /// Listen port
    #[clap(short, long, default_value = "8080")]
    pub port: u16,
    #[clap(short, long, default_value = "3", env = "DOUBAN_API_LIMIT_SIZE")]
    pub limit: usize,
    #[clap(long, default_value = "", env = "DOUBAN_COOKIE")]
    pub cookie: String,
    /// HTTP/SOCKS5 代理地址，例如 http://127.0.0.1:7890 或 socks5://127.0.0.1:1080
    #[clap(long, default_value = "", env = "DOUBAN_PROXY")]
    pub proxy: String,
    #[clap(short, long)]
    pub debug: bool,
}

#[cfg(test)]
mod tests {
    use super::Opt;
    use clap::Parser;
    use lazy_static::lazy_static;
    use std::env;
    use std::sync::Mutex;

    lazy_static! {
        static ref ENV_LOCK: Mutex<()> = Mutex::new(());
    }

    #[test]
    fn parses_proxy_from_flag() {
        let opt = Opt::try_parse_from(["douban-api-rs", "--proxy", "http://127.0.0.1:7890"])
            .unwrap();

        assert_eq!(opt.proxy, "http://127.0.0.1:7890");
    }

    #[test]
    fn parses_proxy_from_env() {
        let _guard = ENV_LOCK.lock().unwrap();
        let old_proxy = env::var_os("DOUBAN_PROXY");

        env::set_var("DOUBAN_PROXY", "http://127.0.0.1:7890");
        let opt = Opt::try_parse_from(["douban-api-rs"]).unwrap();

        assert_eq!(opt.proxy, "http://127.0.0.1:7890");

        match old_proxy {
            Some(value) => env::set_var("DOUBAN_PROXY", value),
            None => env::remove_var("DOUBAN_PROXY"),
        }
    }
}
