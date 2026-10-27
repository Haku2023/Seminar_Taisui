# input data, 11 x 15
"""
Plot All data file
"""
import re

import os

import sys

# import numpy as np
# import plotly.graph_objects as go
import pandas as pd

# import plotly.colors as pc
import plotly.express as px

# from plotly.subplots import make_subplots


OUTPUT_FOLDER = "../plot/pages/"
FLAG = "P6_CIP-tan"  # Central, Upwind, HighUpwind,CIP
filenames = {
    # fold <<{{{
    # HighUpwind
    "P2_HighUpwind": [
        "../data/high_upwind_dt-1_dx-5_u-0.5_C-0.1.dat",
        "../data/high_upwind_dt-1_dx-5_u-1.0_C-0.2.dat",
        "../data/high_upwind_dt-1_dx-5_u-2.5_C-0.5.dat",
        "../data/high_upwind_dt-1_dx-5_u-4.0_C-0.8.dat",
        "../data/high_upwind_dt-1_dx-5_u-5.0_C-1.0.dat",
        "../data/high_upwind_dt-1_dx-5_u-6.0_C-1.2.dat",
    ],
    "P3_HighUpwind": [
        "../data/B-high_upwind_dt-1_dx-5_u-0.5_C-0.1.dat",
        "../data/B-high_upwind_dt-1_dx-5_u-1.0_C-0.2.dat",
        "../data/B-high_upwind_dt-1_dx-5_u-2.5_C-0.5.dat",
        "../data/B-high_upwind_dt-1_dx-5_u-4.0_C-0.8.dat",
        "../data/B-high_upwind_dt-1_dx-5_u-5.0_C-1.0.dat",
        "../data/B-high_upwind_dt-1_dx-5_u-6.0_C-1.2.dat",
    ],
    # CIP
    "P2_CIP": [
        "../data/CIP_dt-1_dx-5_u-0.5_C-0.1.dat",
        "../data/CIP_dt-1_dx-5_u-1.0_C-0.2.dat",
        "../data/CIP_dt-1_dx-5_u-2.5_C-0.5.dat",
        "../data/CIP_dt-1_dx-5_u-4.0_C-0.8.dat",
        "../data/CIP_dt-1_dx-5_u-5.0_C-1.0.dat",
        "../data/CIP_dt-1_dx-5_u-6.0_C-1.2.dat",
    ],
    "P5_CIP": [
        "../data/B-CIP_dt-1_dx-5_u-0.5_C-0.1.dat",
        "../data/B-CIP_dt-1_dx-5_u-1.0_C-0.2.dat",
        "../data/B-CIP_dt-1_dx-5_u-2.5_C-0.5.dat",
        "../data/B-CIP_dt-1_dx-5_u-4.0_C-0.8.dat",
        "../data/B-CIP_dt-1_dx-5_u-5.0_C-1.0.dat",
        "../data/B-CIP_dt-1_dx-5_u-6.0_C-1.2.dat",
    ],
    "P4_CIP": [
        "../data/B-CIP_d_dt-1_dx-5_u-0.1_C-0.0_D-0.0.dat",
        "../data/B-CIP_d_dt-1_dx-5_u-0.5_C-0.1_D-0.0.dat",
        "../data/B-CIP_d_dt-1_dx-5_u-1.0_C-0.2_D-0.0.dat",
    ],
    # Central
    "P2_Central": [
        "../data/central_dt-1_dx-5_u-0.5_C-0.1.dat",
        "../data/central_dt-1_dx-5_u-1.0_C-0.2.dat",
        "../data/central_dt-1_dx-5_u-2.5_C-0.5.dat",
        "../data/central_dt-1_dx-5_u-4.0_C-0.8.dat",
        "../data/central_dt-1_dx-5_u-5.0_C-1.0.dat",
        "../data/central_dt-1_dx-5_u-6.0_C-1.2.dat",
    ],
    "P3_Central": [
        "../data/B-central_dt-1_dx-5_u-0.5_C-0.1.dat",
        "../data/B-central_dt-1_dx-5_u-1.0_C-0.2.dat",
        "../data/B-central_dt-1_dx-5_u-2.5_C-0.5.dat",
        "../data/B-central_dt-1_dx-5_u-4.0_C-0.8.dat",
        "../data/B-central_dt-1_dx-5_u-5.0_C-1.0.dat",
        "../data/B-central_dt-1_dx-5_u-6.0_C-1.2.dat",
    ],
    # Upwind
    "P2_Upwind": [
        "../data/upwind_dt-1_dx-5_u-0.5_C-0.1.dat",
        "../data/upwind_dt-1_dx-5_u-1.0_C-0.2.dat",
        "../data/upwind_dt-1_dx-5_u-2.5_C-0.5.dat",
        "../data/upwind_dt-1_dx-5_u-4.0_C-0.8.dat",
        "../data/upwind_dt-1_dx-5_u-5.0_C-1.0.dat",
        "../data/upwind_dt-1_dx-5_u-6.0_C-1.2.dat",
    ],
    "P3_Upwind": [
        "../data/B-upwind_dt-1_dx-5_u-0.5_C-0.1.dat",
        "../data/B-upwind_dt-1_dx-5_u-1.0_C-0.2.dat",
        "../data/B-upwind_dt-1_dx-5_u-2.5_C-0.5.dat",
        "../data/B-upwind_dt-1_dx-5_u-4.0_C-0.8.dat",
        "../data/B-upwind_dt-1_dx-5_u-5.0_C-1.0.dat",
        "../data/B-upwind_dt-1_dx-5_u-6.0_C-1.2.dat",
    ],
    # fold <<<}}}
    # "P4_CIP": [
    #     "../data/C-CIP_d_dt-1_dx-5_u-2.5_C-0.5_D-0.0.dat",
    # ],
    "P6_CIP-tan": [
        # "../data/T-CIP-tan_d_dt-1_dx-5_u-1.5_C-0.3_D-0.0.dat",
        # "../data/T5.0-CIP-tan_d_dt-1_dx-5_u-1.5_C-0.3_D-0.0.dat",
        # "../data/T5.0-CIP-tan_d_dt-1_dx-5_u-1.5_C-0.3_D-0.0.dat",
        "../data/T1.0v2-CIP-tan_d_dt-1_dx-5_u-1.5_C-0.3_D-0.0.dat",
    ],
    "P5_CIP-tan": [
        "../data/C-CIP-tan_d_dt-1_dx-5_u-0.5_C-0.1_D-0.0.dat",
        "../data/C-CIP-tan_d_dt-1_dx-5_u-1.0_C-0.2_D-0.0.dat",
        "../data/C-CIP-tan_d_dt-1_dx-5_u-2.5_C-0.5_D-0.0.dat",
        "../data/C-CIP-tan_d_dt-1_dx-5_u-4.0_C-0.8_D-0.0.dat",
        "../data/C-CIP-tan_d_dt-1_dx-5_u-5.0_C-1.0_D-0.0.dat",
        "../data/C-CIP-tan_d_dt-1_dx-5_u-6.0_C-1.2_D-0.0.dat",
    ],
    "P4_CIP-tan": [
        "../data/C-CIP-tan_d_dt-1_dx-5_u-0.5_C-0.1_D-0.0.dat",
        "../data/C-CIP-tan_d_dt-1_dx-5_u-1.0_C-0.2_D-0.0.dat",
        "../data/C-CIP-tan_d_dt-1_dx-5_u-2.5_C-0.5_D-0.0.dat",
        "../data/C-CIP-tan_d_dt-1_dx-5_u-4.0_C-0.8_D-0.0.dat",
        "../data/C-CIP-tan_d_dt-1_dx-5_u-5.0_C-1.0_D-0.0.dat",
        "../data/C-CIP-tan_d_dt-1_dx-5_u-6.0_C-1.2_D-0.0.dat",
    ],
    "P4_Upwind": [
        "../data/C-upwind_dt-1_dx-5_u-2.5_C-0.5_D-0.0.dat",
    ],
}
output_file_tmp = f"{OUTPUT_FOLDER}{FLAG}.html"
if not os.path.isdir(OUTPUT_FOLDER):
    print(f"{OUTPUT_FOLDER} not exist")
df = pd.DataFrame()
for filename in filenames[FLAG]:

    dt = re.search(r"dt-(.+?)_", filename)
    dx = re.search(r"dx-(.+?)_", filename)
    u = re.search(r"u-(.+?)_", filename)
    if not dt or not dx or not u:
        sys.exit("dt,dx,u has no value")
    else:
        dt = float(dt.group(1))
        dx = float(dx.group(1))
        u = float(u.group(1))
        print(f"dt: {dt}, dx: {dx}, u: {u}")

    info = re.search(r"data/(.+)\.dat", filename)
    courant = re.search(r"C-(.+)\.dat", filename)
    if info and courant:
        print(f"info: {info.group(1)}")
        print(f"courant: {courant.group(1)}")
        # output_file = f"{OUTPUT_FOLDER}{info.group(1)}.html"
        data = pd.read_csv(filename, header=None)
        df_tmp = data.T.reset_index().rename(columns={"index": "x"})
        # FIX: not known reason, why not using ignore_index
        print(f"df_tmp: {df_tmp}")
        df_tmp = (
            df_tmp.melt(id_vars=["x"], var_name="time_step", value_name="value")
            .assign(time_step=lambda d: d["time_step"].astype(int))
            .sort_values(["x", "time_step"])
            .reset_index(drop=True)
        )
        df_tmp = df_tmp.assign(index=lambda d: d["x"].astype(float))
        df_tmp["Courant"] = courant.group(1)
        df_tmp["group"] = "CFD"
        df = pd.concat([df, df_tmp], ignore_index=True)

    else:
        print("Error: info or courant not exist")

    # df = df[df["time_step"].isin([0, 4, 10])]
    # df = df[df["time_step"].isin([4])]
    # print(f"df: {df}")
    # # Step 2: Theory Output
    # print(f"df_tmp:{df_tmp} ")
    # print(f"df_tmp[time_step]:{df_tmp["time_step"].unique()} ")
    for j in df_tmp["time_step"].unique():
        # print("j: ", j)
        df_theory = df_tmp[df_tmp["time_step"] == 0].copy()
        df_theory["group"] = "Theory"
        df_theory["x"] += u * dt * j / dx
        df_theory["time_step"] = j
        df_theory = df_theory.sort_values(["x"])
        df = pd.concat([df, df_theory], ignore_index=True)
# df["index"] *= dx
df = df[df["time_step"].isin([0, 3, 10, 15, 50, 100, 150])]
# haku test
# pd.set_option("display.max_rows", None)
# print(f"df: {df}")
# print(f"df.tail(20): {df[(df["time_step"]==4) ].tail(100)}")
fig = px.line(
    df,
    x="x",
    y="value",
    animation_frame="Courant",
    color="time_step",
    line_shape="hvh",
    line_dash="group",
    # line_group="group",
    # animation_group="group",
    # color_discrete_sequence=px.colors.qualitative.Dark2,
)
fig.update_layout(
    title={"text": f"<b>{FLAG}</b>", "x": 0.5, "xanchor": "center", "yanchor": "top"},
    yaxis_range=[-0.15, 1.3],
)

# fig.layout.updatemenus[0].buttons[0].args[1]["frame"]["redraw"] = True
fig.show()

# fig.update_traces(
#     marker_color="rgba(0,0,0,0)", marker_line_color="black", marker_line_width=1.5
# )
# prnt(f"output_file: {output_file}")
fig.write_html(output_file_tmp, auto_play=False)

# x = np.arange(15)


# test print
# print(f"data.iloc(2,:):{data.iloc[2,:]}")
# print(f"type: data.iloc(2,:):{type(data.iloc[2,:])}")
# print(f"data.iloc(2,:).values:{data.iloc[2,:].values}")
# print(f"type: data.iloc(2,:).values:{type(data.iloc[2,:].values)}")
# print(f"rows of data: {data.shape[0]}")
# print(f"data: {data}")

# data analysis
# print(f"data: {data}")
# print(f"df: {df}")

# fig = px.line(df, x="index", y=df.columns[0:])
# fig.show()
# print(f"output_file: {output_file}")
# fig.write_html(output_file)

# for i in range(data.shape[0]):
#     df = pd.DataFrame({"x": x, "y": data.iloc[i, :]})
#     fig = px.line(df)
# fig = go.Figure()
