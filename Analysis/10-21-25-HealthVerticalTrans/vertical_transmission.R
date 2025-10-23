
# =================== load libraries ===================
library(tidyverse)
library(dplyr)
library(ggplot2)
library(paletteer)


# =================== load & preprocess data ===================

threshold <- 500

raw_task_data <- read.table("data/HealthVerticalTrans.dat", h=T) |>
  mutate(treatment = sub("^Parasites-", "", treatment))

steal_data <- read.table("data/healthVerticalTransSymInst.dat", h=T) |>
  mutate(treatment = sub("^Parasites-", "", treatment))

clean_task_data <- raw_task_data |>
  select(-uid) |> # remove uid column
  mutate( # order tasks by difficulty
    task = factor(task, levels = c("NOT", "NAND", "ORN", "AND", "OR", 
                                   "ANDN", "NOR", "XOR", "EQU")),
    partner = as.factor(partner))


final_update_only <- clean_task_data |>
  filter(update == 100000)

# =================== plot 1: steal instructions over time ===================

# summarise mean & CI for each treatment
steal_summary <- steal_data |>
  group_by(treatment, update) |>
  summarise(
    avg_steal = mean(sym_steal_ran, na.rm = TRUE),
    sd_steal  = sd(sym_steal_ran, na.rm = TRUE),
    n = n(),
    se_steal  = sd_steal / sqrt(n),
    ci_low  = avg_steal - 1.96 * se_steal,
    ci_high = avg_steal + 1.96 * se_steal,
    .groups = "drop"
  )

ggplot(steal_summary, aes(x = update, y = avg_steal, color = treatment, fill = treatment)) +
  geom_ribbon(aes(ymin = ci_low, ymax = ci_high), alpha = 0.2, color = NA) +
  geom_line(linewidth = 1) +
  labs(
    x = "Update (×1000)",
    y = "Average Steal Count (×1000)",
    color = "Treatment",
    fill = "Treatment",
    title = "Average symbiont steal instruction count over time",
    subtitle = "(Mean ± 95% CI, averaged over all reps per treatment)"
  ) +
  scale_x_continuous(
    breaks = seq(0, 100000, by = 5000), 
    labels = function(x) x / 1000
  ) +
  scale_y_continuous(
    breaks = seq(0, max(steal_summary$avg_steal), by = 20000), 
    labels = function(y) y / 1000
  ) +
  theme(
    legend.position = "bottom"
  )

# =================== plot 2: tasks by parter by treatment ===================


plot2_data <- final_update_only |>
  mutate(
    did_task = count >= threshold,
    treatment = factor(treatment)
  ) |>
  group_by(task, treatment, partner) |>
  summarise(num_reps = sum(did_task), .groups = "drop")

# bar graph
ggplot(plot2_data, aes(x = treatment, y = num_reps, fill = partner)) +
  geom_col(position = "dodge") +  # side-by-side bars for Host vs Symbiont
  facet_wrap(~ task) +
  scale_fill_manual(values = c("Host" = "blue", "Symbiont" = "red")) +
  labs(
    x = "VERTICAL_TRANSMISSION value",
    y = "Number of Reps",
    fill = "Type",
    title = "Number of reps that completed each task by treatment and partner",
    subtitle = "(TRACK_PARENT_TASKS 0, final update only)"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )

# =================== plot 3: avg tasks (all updates) ===================

plot3_data <- clean_task_data |>
  mutate(
    did_task = count >= threshold,
    treatment = factor(treatment)
  ) |>
  group_by(treatment, rep, task, partner) |>  
  summarise(did_task = any(did_task), .groups = "drop") |> 
  group_by(treatment, rep, partner) |>
  summarise(num_tasks_done = sum(did_task), .groups = "drop") |> 
  group_by(treatment, partner) |>
  summarise(avg_tasks_done = mean(num_tasks_done), .groups = "drop")

# side-by-side bar graph
ggplot(plot3_data, aes(x = treatment, y = avg_tasks_done, fill = partner)) +
  geom_col(position = position_dodge(width = 0.8)) +
  scale_fill_viridis_d(option = "turbo", end = 0.9) + 
  labs(
    x = "Treatment",
    y = "Average # of Different Tasks Done",
    fill = "Type",
    title = "Average number of different tasks done by treatment",
    subtitle = "(TRACK_PARENT_TASKS 0, all updates included)"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )
