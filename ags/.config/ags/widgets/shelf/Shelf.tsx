// ags/.config/ags/widgets/shelf/Shelf.tsx

const { Widget } = await Service.import('widget');
const Hyprland = await Service.import('hyprland');

export default () => Widget.Window({
  name: 'shelf',
  anchor: ['top', 'left', 'right'],
  exclusivity: 'exclusive',
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
        Widget.Label(`WS: ${Hyprland.active.workspace.id}`), // Placeholder
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
