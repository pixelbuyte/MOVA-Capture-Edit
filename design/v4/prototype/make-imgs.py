# Inline ../img/*.jpg into src/imgs.ts so the single-file bundle is self-contained.
import base64, pathlib
here = pathlib.Path(__file__).parent
names = ['street', 'skate', 'dancer', 'recreated', 'rooftop', 'stilllife', 'surf', 'portrait']
lines = [f"export const {n} = 'data:image/jpeg;base64,{base64.b64encode((here.parent / 'img' / f'{n}.jpg').read_bytes()).decode()}'" for n in names]
(here / 'src' / 'imgs.ts').write_text('\n'.join(lines) + '\n')
