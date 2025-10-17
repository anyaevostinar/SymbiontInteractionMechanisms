
# =================== load libraries ===================
library(tidyverse)
library(dplyr)
library(ggplot2)
library(viridis)
library(ggsci)
library(paletteer)


# =================== load & preprocess data ===================
ratios <- c("100-10","80-10","70-10","100-15", "150-25","60-10","50-10", 
            "150-35", "100-25", "80-25", "60-25", "150-75", "100-50", 
            "80-40", "60-30", "50-25", "150-100", "60-40", "80-60", 
            "100-100", "50-50")
sums <- c("150-100", "150-75", "100-100", "150-35", "150-25", "100-50",
          "80-60", "100-25", "80-40","100-15","100-10", "80-25", "50-50", 
          "60-40","80-10", "60-30", "60-25","70-10", "50-25", 
          "60-10", "50-10")
threshold <- 500

prelim_1 <- read.table("data/50-25.dat", h=T) |>
  mutate(treatment = "50-25")
prelim_2 <- read.table("data/50-50.dat", h=T) |>
  mutate(treatment = "50-50")
prelim_3 <- read.table("data/100-25.dat", h=T) |>
  mutate(treatment = "100-25")
prelim_4 <- read.table("data/100-50.dat", h=T) |>
  mutate(treatment = "100-50")
prelim_5 <- read.table("data/100-100.dat", h=T) |>
  mutate(treatment = "100-100")
prelim_6 <- read.table("data/150s.dat", h=T) |>
  mutate(treatment = sub("^Parasites-", "", treatment))
prelim_7 <- read.table("data/below-80s.dat", h=T) |>
  mutate(treatment = sub("^Parasites-", "", treatment))
prelim_8 <- read.table("data/ratio.dat", h=T) |>
  mutate(treatment = sub("^Parasites-", "", treatment))

full_data <- bind_rows(prelim_1, prelim_2, prelim_3, prelim_4,
                       prelim_5, prelim_6, prelim_7, prelim_8) |>
  filter(partner != "Symbiont") |>   # remove Symbiont rows
  select(-uid, -partner) |> # remove uid and partner columns
  mutate( # order tasks by difficulty
    task = factor(task, levels = c("NOT", "NAND", "ORN", "AND", "OR", 
                                   "ANDN", "NOR", "XOR", "EQU")),
    rep = as.factor(rep)
  )

final_update_only <- full_data |>
  filter(update == 500000)
  

# =================== plot 1: by sums ===================

# create flag for whether the rep did the task
plot1_data <- final_update_only |>
  mutate(
    did_task = count >= threshold,
    treatment = factor(treatment, levels = sums)) |>
  group_by(task, treatment) |>
  summarise(num_reps = sum(did_task), .groups = "drop")

# bar graph
ggplot(plot1_data, aes(x = treatment, y = num_reps, fill = treatment)) +
  geom_col() +
  facet_wrap(~ task) +
  scale_fill_viridis_d(option = "turbo", end = 0.9) + 
  labs(
    x = "Treatment",
    y = "Number of Reps",
    title = "Number of reps that completed each task by treatment\n
    (final update only, treatments ordered by decreasing sum)"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )

# =================== plot 2: by ratios ===================

# create flag for whether the rep did the task
plot2_data <- final_update_only |>
  mutate(
    did_task = count >= threshold,
    treatment = factor(treatment, levels = ratios)) |>
  group_by(task, treatment) |>
  summarise(num_reps = sum(did_task), .groups = "drop")

# bar graph
ggplot(plot2_data, aes(x = treatment, y = num_reps, fill = treatment)) +
  geom_col() +
  facet_wrap(~ task) +
  scale_fill_viridis_d(option = "turbo", end = 0.9) + 
  labs(
    x = "Treatment",
    y = "Number of Reps",
    title = "Number of reps that completed each task by treatment",
    subtitle ="(final update only, treatments ordered by increasing ratio)"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )

# =================== identical version using ALL updates ===================

plot1_data_all <- full_data |>
  mutate(
    did_task = count >= threshold,
    treatment = factor(treatment, levels = sums)) |>
  group_by(task, treatment) |>
  summarise(num_reps = sum(did_task), .groups = "drop")

ggplot(plot1_data_all, aes(x = treatment, y = num_reps, fill = treatment)) +
  geom_col() +
  facet_wrap(~ task) +
  scale_fill_viridis_d(option = "turbo", end = 0.9) + 
  labs(
    x = "Treatment",
    y = "Number of Reps",
    title = "Number of reps that completed each task by treatment\n(all updates included, ordered by decreasing sum)"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )

plot2_data_all <- full_data |>
  mutate(
    did_task = count >= threshold,
    treatment = factor(treatment, levels = ratios)) |>
  group_by(task, treatment) |>
  summarise(num_reps = sum(did_task), .groups = "drop")

ggplot(plot2_data_all, aes(x = treatment, y = num_reps, fill = treatment)) +
  geom_col() +
  facet_wrap(~ task) +
  scale_fill_viridis_d(option = "turbo", end = 0.9) + 
  labs(
    x = "Treatment",
    y = "Number of Reps",
    title = "Number of reps that completed each task by treatment",
    subtitle ="(all updates included, ordered by increasing ratio)"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )  

# =================== plot 3: avg number of different tasks done (all updates) ===================

plot3_data <- full_data |>
  mutate(
    did_task = count >= threshold,
    treatment = factor(treatment, levels = ratios)
  ) |>
  group_by(treatment, rep, task) |>
  summarise(did_task = any(did_task), .groups = "drop") |> 
  group_by(treatment, rep) |>
  summarise(num_tasks_done = sum(did_task), .groups = "drop") |> 
  group_by(treatment) |>
  summarise(avg_tasks_done = mean(num_tasks_done), .groups = "drop") 

# bar graph
ggplot(plot3_data, aes(x = treatment, y = avg_tasks_done, fill = treatment)) +
  geom_col() +
  scale_fill_viridis_d(option = "turbo", end = 0.9) + 
  labs(
    x = "Treatment",
    y = "Average # of Different Tasks Done",
    title = "Average number of different tasks done by treatment",
    subtitle = "(all updates included, ordered by increasing ratio)"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "none"
  )

