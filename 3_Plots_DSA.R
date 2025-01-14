source("1_Model_Base.R")

### Load required packages
library(ggplot2)   # for plots
library(cowplot)   # for nicer themes in plots
library(showtext)  # for custom fonts in plots
library(scales)    # for plots scale transformations



### default settings for all plots
theme_set(theme_classic(base_family = "univers"))
font_add("univers",   "fonts/UniversRegular.ttf")
showtext_auto()

width      <- 0.75  # width of columns in plot (value between 0 and 1)
ylab       <- ylab("Cost per DALY averted ($)")
xlab       <- xlab("")
xscale     <- scale_x_discrete(name=" ")
border     <- panel_border(color = "#444444", size = 0.3, linetype = 1)
scaleFill  <- scale_fill_manual(values = c("#FEDAB8", "#A162D0"))
scaleColor <- scale_color_manual(values = c("black", "black"))
theme      <- theme(axis.title.x      = element_text(size = 13), 
                    axis.title.y      = element_text(size = 13), 
                    axis.text         = element_text(size = 12,  color = "black"),
                    axis.line         = element_line(linewidth = 0.1, color = "#444444"),
                    axis.ticks        = element_line(linewidth = 0.3, color = "black"),
                    axis.ticks.length = unit(0.1, "cm"),
                    panel.grid.major  = element_line(linewidth = 0.2, colour = "gray97"),
                    plot.title        = element_text(size = 14, colour = "black", 
                                                     margin=margin(t=5, b=5), hjust = 0.5),
                    legend.position = c(1, 0), 
                    legend.justification = c(1.1, 0), 
                    legend.background = element_rect(fill="transparent"),
                    legend.text = element_text(size=11),   # change legend text font size
                    legend.title = element_blank(),        # change legend title font size
                    legend.key.size = unit(0.3, 'cm')      # change legend key size
) 



### Function for rescaling plots to a tornado
offset_trans <- function(offset=0) {
  trans_new(paste0("offset-", format(offset)), function(x) x-offset, function(x) x+offset)
}





##### Fig E5  ##################

# Get the base case icer value
baseCase <- covidData_Base %>%  
  filter(group=="A" & immuneEscape=="1.50 yr" & tpLevel=="low TP" & 
           scenario=="High-risk boost" & boostStart=="2.00 yr") %>% 
  .$icer
baseCase

# Filter scenarios needed and use better parameter names
df <- covidData_OWSA %>%  
  filter(group=="A" & immuneEscape=="1.50 yr" & tpLevel=="low TP" & 
           scenario=="High-risk boost" & boostStart=="2.00 yr") %>% 
  select (-icerDonated) %>%
  pivot_wider(names_from = result, values_from = icer) %>% 
  mutate(range = abs(High - Low)) %>% 
  arrange(range) %>% 
  mutate(parameter = as.character(parameter)) %>% # Convert parameter to character data type
  mutate(parameter = replace(parameter, parameter=="Cost vax delivery (A)", "Cost of vaccine delivery")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost home-based (A)", "Cost of home-based care")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost bedday ICU (A)", "Cost per ICU bed day")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost bedday ward (A)", "Cost per non-ICU bed day")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost vaccine dose (A)", "Cost of vaccine per dose")) %>%
  mutate(parameter = replace(parameter, parameter=="Days sick moderate", "Duration of illness, moderate")) %>%
  mutate(parameter = replace(parameter, parameter=="Days sick postacute", "Duration of illness, post-acute")) %>%
  mutate(parameter = replace(parameter, parameter=="Prop. doses wasted", "Dose wastage proportion")) %>%
  mutate(parameter = replace(parameter, parameter=="Dis. weight postacute", "Disability Weight, post-acute")) %>%
  mutate(parameter = replace(parameter, parameter=="Dis. weight moderate", "Disability Weight, moderate")) %>%
  mutate(parameter=factor(x=parameter, levels=parameter)) %>% 
  pivot_longer(names_to='type', values_to='value', Low:High) %>% 
  slice_tail(n=20) # keep only the last 20 observations

df <- df %>%
  mutate(type = replace(type, type=="High", "High value input")) %>% 
  mutate(type = replace(type, type=="Low", "Low value input"))

# Make tornado plot
ggplot(df, aes(x=parameter,y=value, fill=type, colour=type)) +
  geom_bar(data=df[df$type=="Low value input",],  aes(x=parameter,y=value), stat="identity", linewidth=0.1) +
  geom_bar(data=df[df$type=="High value input",], aes(x=parameter,y=value), stat="identity", linewidth=0.1) +
  geom_hline(yintercept = baseCase, linetype = "solid", linewidth=0.25) +
  theme + xscale + coord_flip() + border + scaleFill + scaleColor +
  scale_y_continuous(name="Incremental cost-effectiveness ratio ($)", trans=offset_trans(offset=baseCase), 
                     limits = c(1000, 10000), breaks=breaks_extended(7)) +
  geom_text(data = subset(df, type=="Low value input"), show.legend = FALSE, 
            aes(label = comma(round(value))), 
            hjust= ifelse(subset(df, type=="Low value input", select = value) < baseCase, 1.15, -0.15),
            size = 4, family = "univers") +
  geom_text(data = subset(df, type=="High value input"), show.legend = FALSE, 
            aes(label = comma(round(value))), 
            hjust= ifelse(subset(df, type=="High value input", select = value) < baseCase, 1.15, -0.15),
            size = 4, family = "univers") +
  ggtitle("Scenario: older population, 80% initial vaccination coverage, low TP \n immune escape starts 1.5 yr, boosting at 2.0 yr")

ggsave(height=6, width=9, dpi=600, file="plots/figure_E5.pdf")





##### Fig E5 - high TP version  ##################

# Get the base case icer value
baseCase <- covidData_Base %>%  
  filter(group=="A" & immuneEscape=="1.50 yr" & tpLevel=="high TP" & 
           scenario=="High-risk boost" & boostStart=="2.00 yr") %>% 
  .$icer
baseCase

# Filter scenarios needed and use better parameter names
df <- covidData_OWSA %>%  
  filter(group=="A" & immuneEscape=="1.50 yr" & tpLevel=="high TP" & 
           scenario=="High-risk boost" & boostStart=="2.00 yr") %>% 
  select (-icerDonated) %>%
  pivot_wider(names_from = result, values_from = icer) %>% 
  mutate(range = abs(High - Low)) %>% 
  arrange(range) %>% 
  mutate(parameter = as.character(parameter)) %>% # Convert parameter to character data type
  mutate(parameter = replace(parameter, parameter=="Cost vax delivery (A)", "Cost of vaccine delivery")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost home-based (A)", "Cost of home-based care")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost bedday ICU (A)", "Cost per ICU bed day")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost bedday ward (A)", "Cost per non-ICU bed day")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost vaccine dose (A)", "Cost of vaccine per dose")) %>%
  mutate(parameter = replace(parameter, parameter=="Days sick moderate", "Duration of illness, moderate")) %>%
  mutate(parameter = replace(parameter, parameter=="Days sick postacute", "Duration of illness, post-acute")) %>%
  mutate(parameter = replace(parameter, parameter=="Prop. doses wasted", "Dose wastage proportion")) %>%
  mutate(parameter = replace(parameter, parameter=="Dis. weight postacute", "Disability Weight, post-acute")) %>%
  mutate(parameter = replace(parameter, parameter=="Dis. weight moderate", "Disability Weight, moderate")) %>%
  mutate(parameter=factor(x=parameter, levels=parameter)) %>% 
  pivot_longer(names_to='type', values_to='value', Low:High) %>% 
  slice_tail(n=20) # keep only the last 20 observations

df <- df %>%
  mutate(type = replace(type, type=="High", "High value input")) %>% 
  mutate(type = replace(type, type=="Low", "Low value input"))

# Make tornado plot
ggplot(df, aes(x=parameter,y=value, fill=type, colour=type)) +
  geom_bar(data=df[df$type=="Low value input",],  aes(x=parameter,y=value), stat="identity", linewidth=0.1) +
  geom_bar(data=df[df$type=="High value input",], aes(x=parameter,y=value), stat="identity", linewidth=0.1) +
  geom_hline(yintercept = baseCase, linetype = "solid", linewidth=0.25) +
  theme + xscale + coord_flip() + border + scaleFill + scaleColor +
  scale_y_continuous(name="Incremental cost-effectiveness ratio ($)", trans=offset_trans(offset=baseCase),  breaks=breaks_extended(7) ) + #, 
                     # limits = c(1000, 10000), breaks=breaks_extended(7)) +
  geom_text(data = subset(df, type=="Low value input"), show.legend = FALSE, 
            aes(label = comma(round(value))), 
            hjust= ifelse(subset(df, type=="Low value input", select = value) < baseCase, 1.15, -0.15),
            size = 4, family = "univers") +
  geom_text(data = subset(df, type=="High value input"), show.legend = FALSE, 
            aes(label = comma(round(value))), 
            hjust= ifelse(subset(df, type=="High value input", select = value) < baseCase, 1.15, -0.15),
            size = 4, family = "univers") +
  ggtitle("Scenario: older population, 80% initial vaccination coverage, high TP \n immune escape starts 1.5 yr, boosting at 2.0 yr")

ggsave(height=6, width=9, dpi=600, file="plots/figure_E5_high_TP.pdf")




##### Fig E6  ##################

# Get the base case icer value
baseCase <- covidData_Base %>%  
  filter(group=="B" & immuneEscape=="2.50 yr" & tpLevel=="high TP" & 
           scenario=="High-risk boost" & boostStart=="2.00 yr") %>% 
  .$icer
baseCase

# Filter scenarios needed and use better parameter names
df <- covidData_OWSA %>%  
  filter(group=="B" & immuneEscape=="2.50 yr" & tpLevel=="high TP" & 
           scenario=="High-risk boost" & boostStart=="2.00 yr") %>% 
  select (-icerDonated) %>%
  pivot_wider(names_from = result, values_from = icer) %>% 
  mutate(range = abs(High - Low)) %>% 
  arrange(range) %>% 
  mutate(parameter = as.character(parameter)) %>% # Convert parameter to character data type
  mutate(parameter = replace(parameter, parameter=="Cost vax delivery (B)", "Cost of vaccine delivery")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost home-based (B)", "Cost of home-based care")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost bedday ICU (B)", "Cost per ICU bed day")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost bedday ward (B)", "Cost per non-ICU bed day")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost vaccine dose (B)", "Cost of vaccine per dose")) %>%
  mutate(parameter = replace(parameter, parameter=="Days sick moderate", "Duration of illness, moderate")) %>%
  mutate(parameter = replace(parameter, parameter=="Days sick postacute", "Duration of illness, post-acute")) %>%
  mutate(parameter = replace(parameter, parameter=="Prop. doses wasted", "Dose wastage proportion")) %>%
  mutate(parameter = replace(parameter, parameter=="Dis. weight postacute", "Disability Weight, post-acute")) %>%
  mutate(parameter = replace(parameter, parameter=="Dis. weight moderate", "Disability Weight, moderate")) %>%
  mutate(parameter=factor(x=parameter, levels=parameter)) %>% 
  pivot_longer(names_to='type', values_to='value', Low:High) %>% 
  slice_tail(n=20) # keep only the last 20 observations

df <- df %>%
  mutate(type = replace(type, type=="High", "High value input")) %>% 
  mutate(type = replace(type, type=="Low", "Low value input"))


# Make tornado plot
ggplot(df, aes(x=parameter,y=value, fill=type, colour=type)) +
  geom_bar(data=df[df$type=="Low value input",],  aes(x=parameter,y=value), stat="identity", linewidth=0.1) +
  geom_bar(data=df[df$type=="High value input",], aes(x=parameter,y=value), stat="identity", linewidth=0.1) +
  geom_hline(yintercept = baseCase, linetype = "solid", size=0.25) +
  theme + xscale + coord_flip() + border + scaleFill + scaleColor +
  scale_y_continuous(name="Incremental cost-effectiveness ratio ($)", trans=offset_trans(offset=baseCase), 
                     limits = c(-4000, 1800), breaks=breaks_extended(7)) +
  geom_text(data = subset(df, type=="Low value input"), show.legend = FALSE, 
            aes(label = comma(round(value))), 
            hjust= ifelse(subset(df, type=="Low value input", select = value) < baseCase, 1.15, -0.15),
            size = 4, family = "univers") +
  geom_text(data = subset(df, type=="High value input"), show.legend = FALSE, 
            aes(label = comma(round(value))), 
            hjust= ifelse(subset(df, type=="High value input", select = value) < baseCase, 1.15, -0.15),
            size = 4, family = "univers") +
  ggtitle("Scenario: younger population, 80% initial vaccination coverage, high TP \n immune escape starts 2.5 yr, boosting at 2.0 yr")
            
ggsave(height=6, width=9, dpi=600, file="plots/figure_E6.pdf")


##### Fig E9  ##################

# Get the base case icer value
baseCase <- covidData_Base %>%  
  filter(group=="B" & immuneEscape=="1.50 yr" & 
           vaxCoverage=="80%" &
           scenario=="6-monthly boost") %>% 
  .$icer
baseCase

# Filter scenarios needed and use better parameter names
df <- covidData_OWSA %>%  
  filter(group=="B" & immuneEscape=="1.50 yr" & 
           vaxCoverage=="80%" &
           scenario=="6-monthly boost") %>% 
  select (-icerDonated) %>%
  pivot_wider(names_from = result, values_from = icer) %>% 
  mutate(range = abs(High - Low)) %>% 
  arrange(range) %>% 
  mutate(parameter = as.character(parameter)) %>% # Convert parameter to character data type
  mutate(parameter = replace(parameter, parameter=="Cost vax delivery (B)", "Cost of vaccine delivery")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost home-based (B)", "Cost of home-based care")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost bedday ICU (B)", "Cost per ICU bed day")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost bedday ward (B)", "Cost per non-ICU bed day")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost vaccine dose (B)", "Cost of vaccine per dose")) %>%
  mutate(parameter = replace(parameter, parameter=="Days sick moderate", "Duration of illness, moderate")) %>%
  mutate(parameter = replace(parameter, parameter=="Days sick postacute", "Duration of illness, post-acute")) %>%
  mutate(parameter = replace(parameter, parameter=="Prop. doses wasted", "Dose wastage proportion")) %>%
  mutate(parameter = replace(parameter, parameter=="Dis. weight postacute", "Disability Weight, post-acute")) %>%
  mutate(parameter = replace(parameter, parameter=="Dis. weight moderate", "Disability Weight, moderate")) %>%
  mutate(parameter=factor(x=parameter, levels=parameter)) %>% 
  pivot_longer(names_to='type', values_to='value', Low:High) %>% 
  slice_tail(n=20) # keep only the last 20 observations

df <- df %>%
  mutate(type = replace(type, type=="High", "High value input")) %>% 
  mutate(type = replace(type, type=="Low", "Low value input"))


# Make tornado plot
figure_6month_1 <- ggplot(df, aes(x=parameter,y=value, fill=type, colour=type)) +
  geom_bar(data=df[df$type=="Low value input",],  aes(x=parameter,y=value), stat="identity", linewidth=0.1) +
  geom_bar(data=df[df$type=="High value input",], aes(x=parameter,y=value), stat="identity", linewidth=0.1) +
  geom_hline(yintercept = baseCase, linetype = "solid", size=0.25) +
  theme + xscale + coord_flip() + border + scaleFill + scaleColor +
  scale_y_continuous(name="Incremental cost-effectiveness ratio ($)", trans=offset_trans(offset=baseCase), 
                     limits = c(-16000, 11000), breaks=breaks_extended(7)) +
  geom_text(data = subset(df, type=="Low value input"), show.legend = FALSE, 
            aes(label = comma(round(value))), 
            hjust= ifelse(subset(df, type=="Low value input", select = value) < baseCase, 1.15, -0.15),
            size = 4, family = "univers") +
  geom_text(data = subset(df, type=="High value input"), show.legend = FALSE, 
            aes(label = comma(round(value))), 
            hjust= ifelse(subset(df, type=="High value input", select = value) < baseCase, 1.15, -0.15),
            size = 4, family = "univers") +
  ggtitle("Scenario: younger population, 80% initial vaccination coverage \n immune escape starts 1.5 yr, half-yearly boosting")

# ggsave(height=6, width=9, dpi=600, file="plots/figure_6month_1.pdf")

# Get the base case icer value
baseCase <- covidData_Base %>%  
  filter(group=="B" & immuneEscape=="2.50 yr" & 
           vaxCoverage=="80%" &
           scenario=="6-monthly boost") %>% 
  .$icer
baseCase

# Filter scenarios needed and use better parameter names
df <- covidData_OWSA %>%  
  filter(group=="B" & immuneEscape=="2.50 yr" & 
           vaxCoverage=="80%" &
           scenario=="6-monthly boost") %>%
  select (-icerDonated) %>%
  pivot_wider(names_from = result, values_from = icer) %>% 
  mutate(range = abs(High - Low)) %>% 
  arrange(range) %>% 
  mutate(parameter = as.character(parameter)) %>% # Convert parameter to character data type
  mutate(parameter = replace(parameter, parameter=="Cost vax delivery (B)", "Cost of vaccine delivery")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost home-based (B)", "Cost of home-based care")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost bedday ICU (B)", "Cost per ICU bed day")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost bedday ward (B)", "Cost per non-ICU bed day")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost vaccine dose (B)", "Cost of vaccine per dose")) %>%
  mutate(parameter = replace(parameter, parameter=="Days sick moderate", "Duration of illness, moderate")) %>%
  mutate(parameter = replace(parameter, parameter=="Days sick postacute", "Duration of illness, post-acute")) %>%
  mutate(parameter = replace(parameter, parameter=="Prop. doses wasted", "Dose wastage proportion")) %>%
  mutate(parameter = replace(parameter, parameter=="Dis. weight postacute", "Disability Weight, post-acute")) %>%
  mutate(parameter = replace(parameter, parameter=="Dis. weight moderate", "Disability Weight, moderate")) %>%
  mutate(parameter=factor(x=parameter, levels=parameter)) %>% 
  pivot_longer(names_to='type', values_to='value', Low:High) %>% 
  slice_tail(n=20) # keep only the last 20 observations

df <- df %>%
  mutate(type = replace(type, type=="High", "High value input")) %>% 
  mutate(type = replace(type, type=="Low", "Low value input"))


# Make tornado plot
figure_6month_2 <- ggplot(df, aes(x=parameter,y=value, fill=type, colour=type)) +
  geom_bar(data=df[df$type=="Low value input",],  aes(x=parameter,y=value), stat="identity", linewidth=0.1) +
  geom_bar(data=df[df$type=="High value input",], aes(x=parameter,y=value), stat="identity", linewidth=0.1) +
  geom_hline(yintercept = baseCase, linetype = "solid", size=0.25) +
  theme + xscale + coord_flip() + border + scaleFill + scaleColor +
  scale_y_continuous(name="Incremental cost-effectiveness ratio ($)", trans=offset_trans(offset=baseCase), 
                     limits = c(-16000, 11000), breaks=breaks_extended(7)) +
  geom_text(data = subset(df, type=="Low value input"), show.legend = FALSE, 
            aes(label = comma(round(value))), 
            hjust= ifelse(subset(df, type=="Low value input", select = value) < baseCase, 1.15, -0.15),
            size = 4, family = "univers") +
  geom_text(data = subset(df, type=="High value input"), show.legend = FALSE, 
            aes(label = comma(round(value))), 
            hjust= ifelse(subset(df, type=="High value input", select = value) < baseCase, 1.15, -0.15),
            size = 4, family = "univers") +
  ggtitle("Scenario: younger population, 80% initial vaccination coverage \n immune escape starts 2.5 yr, half-yearly boosting")

# ggsave(height=6, width=9, dpi=600, file="plots/figure_6month_2.pdf")

# Figure 6 monthly = figure_6month_1.5yr + figure_6month_2.5yr
# plot_grid(figure_6month_1, figure_6month_2, rows = 2)
# ggsave(height=8, width=10, dpi=600, file="plots/figure_6month.pdf")


plot_grid(figure_6month_1, figure_6month_2, rows = 2, labels = c("(a)","(b)"),label_x=0.12,label_y = 0.98)
ggsave(height=8, width=10, dpi=600, file="plots/figure_E9.pdf")



### Fig: vaccine donated perspective####
# Get the base case icer value
baseCase <- covidData_Base %>%  
  filter(group=="B" & immuneEscape=="2.00 yr" & tpLevel=="high TP" & 
           scenario=="Random boost" & boostStart=="2.00 yr") %>% 
  .$icerDonated
baseCase

# Filter scenarios needed and use better parameter names
df <- covidData_OWSA %>%  
  filter(group=="B" & immuneEscape=="2.00 yr" & tpLevel=="high TP" & 
           scenario=="Random boost" & boostStart=="2.00 yr") %>%
  select(-icer) %>%
  pivot_wider(names_from = result, values_from = icerDonated) %>% 
  mutate(range = abs(High - Low)) %>% 
  arrange(range) %>% 
  mutate(parameter = as.character(parameter)) %>% # Convert parameter to character data type
  mutate(parameter = replace(parameter, parameter=="Cost vax delivery (B)", "Cost of vaccine delivery")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost home-based (B)", "Cost of home-based care")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost bedday ICU (B)", "Cost per ICU bed day")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost bedday ward (B)", "Cost per non-ICU bed day")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost vaccine dose (B)", "Cost of vaccine per dose")) %>%
  mutate(parameter = replace(parameter, parameter=="Days sick moderate", "Duration of illness, moderate")) %>%
  mutate(parameter = replace(parameter, parameter=="Days sick postacute", "Duration of illness, post-acute")) %>%
  mutate(parameter = replace(parameter, parameter=="Prop. doses wasted", "Dose wastage proportion")) %>%
  mutate(parameter = replace(parameter, parameter=="Dis. weight postacute", "Disability Weight, post-acute")) %>%
  mutate(parameter = replace(parameter, parameter=="Dis. weight moderate", "Disability Weight, moderate")) %>%
  mutate(parameter=factor(x=parameter, levels=parameter)) %>% 
  pivot_longer(names_to='type', values_to='value', Low:High) %>% 
  slice_tail(n=20) # keep only the last 20 observations

df <- df %>%
  mutate(type = replace(type, type=="High", "High value input")) %>% 
  mutate(type = replace(type, type=="Low", "Low value input"))


# Make tornado plot
figure_donated1 <- ggplot(df, aes(x=parameter,y=value, fill=type, colour=type)) +
  geom_bar(data=df[df$type=="Low value input",],  aes(x=parameter,y=value), stat="identity", linewidth=0.1) +
  geom_bar(data=df[df$type=="High value input",], aes(x=parameter,y=value), stat="identity", linewidth=0.1) +
  geom_hline(yintercept = baseCase, linetype = "solid", size=0.25) +
  theme + xscale + coord_flip() + border + scaleFill + scaleColor +
  scale_y_continuous(name="Incremental cost-effectiveness ratio ($)", trans=offset_trans(offset=baseCase), 
                     limits = c(-16000, 22000), breaks=breaks_extended(8)) +
  geom_text(data = subset(df, type=="Low value input"), show.legend = FALSE, 
            aes(label = comma(round(value))), 
            hjust= ifelse(subset(df, type=="Low value input", select = value) < baseCase, 1.15, -0.15),
            size = 4, family = "univers") +
  geom_text(data = subset(df, type=="High value input"), show.legend = FALSE, 
            aes(label = comma(round(value))), 
            hjust= ifelse(subset(df, type=="High value input", select = value) < baseCase, 1.15, -0.15),
            size = 4, family = "univers") +
  ggtitle("Vaccine Donated Scenario: younger population, 80% initial vaccination coverage \n high TP, immune escape starts 2.0 yr, boosting at 2.0 yr")

# Get the base case icer value
baseCase <- covidData_Base %>%  
  filter(group=="C" & immuneEscape=="2.00 yr" & tpLevel=="high TP" & 
           scenario=="High-risk boost" & boostStart=="2.00 yr") %>% 
  .$icerDonated
baseCase

# Filter scenarios needed and use better parameter names
df <- covidData_OWSA %>%  
  filter(group=="C" & immuneEscape=="2.00 yr" & tpLevel=="high TP" & 
           scenario=="High-risk boost" & boostStart=="2.00 yr") %>%
  select(-icer) %>%
  pivot_wider(names_from = result, values_from = icerDonated) %>% 
  mutate(range = abs(High - Low)) %>% 
  arrange(range) %>% 
  mutate(parameter = as.character(parameter)) %>% # Convert parameter to character data type
  mutate(parameter = replace(parameter, parameter=="Cost vax delivery (C)", "Cost of vaccine delivery")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost home-based (C)", "Cost of home-based care")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost bedday ICU (C)", "Cost per ICU bed day")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost bedday ward (C)", "Cost per non-ICU bed day")) %>%
  mutate(parameter = replace(parameter, parameter=="Cost vaccine dose (C)", "Cost of vaccine per dose")) %>%
  mutate(parameter = replace(parameter, parameter=="Days sick moderate", "Duration of illness, moderate")) %>%
  mutate(parameter = replace(parameter, parameter=="Days sick postacute", "Duration of illness, post-acute")) %>%
  mutate(parameter = replace(parameter, parameter=="Prop. doses wasted", "Dose wastage proportion")) %>%
  mutate(parameter = replace(parameter, parameter=="Dis. weight postacute", "Disability Weight, post-acute")) %>%
  mutate(parameter = replace(parameter, parameter=="Dis. weight moderate", "Disability Weight, moderate")) %>%
  mutate(parameter=factor(x=parameter, levels=parameter)) %>% 
  pivot_longer(names_to='type', values_to='value', Low:High) %>% 
  slice_tail(n=20) # keep only the last 20 observations

df <- df %>%
  mutate(type = replace(type, type=="High", "High value input")) %>% 
  mutate(type = replace(type, type=="Low", "Low value input"))


# Make tornado plot
figure_donated2 <- ggplot(df, aes(x=parameter,y=value, fill=type, colour=type)) +
  geom_bar(data=df[df$type=="Low value input",],  aes(x=parameter,y=value), stat="identity", linewidth=0.1) +
  geom_bar(data=df[df$type=="High value input",], aes(x=parameter,y=value), stat="identity", linewidth=0.1) +
  geom_hline(yintercept = baseCase, linetype = "solid", size=0.25) +
  theme + xscale + coord_flip() + border + scaleFill + scaleColor +
  scale_y_continuous(name="Incremental cost-effectiveness ratio ($)", trans=offset_trans(offset=baseCase), 
                     limits = c(-800, 800), breaks=breaks_extended(8)) +
  geom_text(data = subset(df, type=="Low value input"), show.legend = FALSE, 
            aes(label = comma(round(value))), 
            hjust= ifelse(subset(df, type=="Low value input", select = value) < baseCase, 1.15, -0.15),
            size = 4, family = "univers") +
  geom_text(data = subset(df, type=="High value input"), show.legend = FALSE, 
            aes(label = comma(round(value))), 
            hjust= ifelse(subset(df, type=="High value input", select = value) < baseCase, 1.15, -0.15),
            size = 4, family = "univers") +
  ggtitle("Vaccine Donated Scenario: younger population, 20% initial vaccination coverage \n high TP, immune escape starts 2.0 yr, boosting at 2.0 yr")

plot_grid(figure_donated1, figure_donated2, rows = 2, labels = c("(a)","(b)"),label_x=0.12,label_y = 0.98)

ggsave(height=8, width=10, dpi=600, file="plots/figure_donated.pdf")


