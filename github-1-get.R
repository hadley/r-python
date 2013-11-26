library(httr)
library(lubridate)
library(dplyr)

# Github API -------------------------------------------------------------------

user <- Sys.getenv("GITHUB_USER")
pwd <- Sys.getenv("GITHUB_PASS")
if (user == "" || pwd == "") {
  stop("Set GITHUB_USER and GITHUB_PASS env vars", call. = FALSE)
}

# install_github("rgithub", "cscheid")
base <- "https://api.github.com"
config <- c(
  authenticate(user, pwd, type = "basic"), 
  add_headers(
    Accept = "application/vnd.github.preview", 
    "User-Agent" = "hadley/r-python"
  )
)
rate_limit <- function() {
  content(GET("https://api.github.com/rate_limit", config))  
}

repos <- function(query) {
  Sys.sleep(60 / 20) # 20 requests per minute
  path <- paste0(base, "/search/repositories")
  qs <- list(q = paste("language:r", query), per_page = 1)
  
  req <- GET(path, config, query = qs)
  stop_for_status(req)
  content(req, as = "parsed")$total_count
}

# Collect and cache data -------------------------------------------------------
cur_year <- year(today())

past <- expand.grid(year = 2011:(cur_year - 1), month = 1:12)
pres <- data.frame(year = cur_year, month = 1:(month(today()) - 2))
months <- rbind(past, pres)

all <- rbind(cbind(months, lang = "r"), cbind(months, lang = "python"))
all <- all %.% group_by(lang) %.% arrange(year, month)
all <- all %.% mutate(
  year_next = lead(year, default = cur_year), 
  month_next = lead(month, default = month(today()) - 1)
)

all$query <- paste0("language:", all$lang, 
  " created:", all$year, "-", all$month, "..", 
  all$year_next, "-", all$month_next)
all$count <- NA

missing <- seq_along(all$count)[is.na(all$count)]
for(i in missing) {
  all$count[[i]] <- repos(all$query[i])
  cat(".")
}
saveRDS(all, "github.rds")
