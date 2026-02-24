// ags/.config/ags/widgets/shelf/Shelf.tsx

const { Widget } = await Service.import('widget');
const Hyprland = await Service.import('hyprland');

export default () => Widget.Window({
  name: 'shelf',
  anchor: ['top', 'left', 'right'],
  exclusivity: 'exclusive',
  layer: 'top',
  margins: [0, 0, 0, 0],
  child: Widget.CenterBox({
    className: 'shelf',
    startWidget: Widget.Box({
      className: 'shelf__left',
      children: [
        Widget.Label('Launcher'), // Placeholder
      ],
    }),
    centerWidget: Widget.Box({
      className: 'shelf__center',
      children: [
        Widget.Label({
          label: Hyprland.active.workspace.bind('id')
            .as(id => `WS: ${id}`),
        }),
      ],
    }),
    endWidget: Widget.Box({
      className: 'shelf__right',
      children: [
        Widget.Label('System Tray'), // Placeholder
      ],
    }),
  }),
});
