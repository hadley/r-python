library(httr)
library(lubridate)
library(dplyr)

# Github API -------------------------------------------------------------------

pat <- Sys.getenv("GITHUB_PAT")
if (pat == "") {
  stop("Set GITHUB_PAT env vars", call. = FALSE)
}

# install_github("rgithub", "cscheid")
base <- "https://api.github.com"
config <- c(
  authenticate(pat, "", type = "basic"), 
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
  qs <- list(q = query, per_page = 1)
  
  req <- GET(path, config, query = qs)
  stop_for_status(req)
  content(req, as = "parsed")$total_count
}

# Collect and cache data -------------------------------------------------------
cur_year <- year(today())

past <- expand.grid(year = 2011:(cur_year - 1), month = 1:12)
pres <- data.frame(year = cur_year, month = 1:(month(today()) - 2))
months <- bind_rows(past, pres)

all <- bind_rows(
  months %>% mutate(lang = "r"),
  months %>% mutate(lang = "python")
) 

last_month <- month(today()) - 1L
all <- all %>% 
  group_by(lang) %>% 
  arrange(year, month) %>%
  mutate(
    year_next = lead(year, default = cur_year), 
    month_next = lead(month, default = last_month),
    query = paste0("language:", lang,  " created:", year, "-", month, "..", 
      year_next, "-", month_next),
    count = NA_integer_
  )

if (file.exists("github.rds")) {
  cached <- readRDS("github.rds") %>% ungroup() %>% mutate(lang = as.character(lang))
  
  all <- bind_rows(
    cached,
    all %>% anti_join(cached, c("year", "month", "lang"))
  )
}

missing <- seq_along(all$count)[is.na(all$count)]
for (i in missing) {
  all$count[[i]] <- repos(all$query[i])
  cat(".")
}
saveRDS(all, "github.rds")
