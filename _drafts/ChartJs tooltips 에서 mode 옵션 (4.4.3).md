---
주제 태그:
  - "#chartjs"
at: 2024-05-31 08:45
tags:
  - chartjs
  - JavaScript
gh-page: true
created: 2024-06-16 23:52
updated: 2025-03-31 13:22
---
### memo
- tooltip 설정 중 'mode' 설정에 따라 **여러 데이터가 loop 를 돌며 callback 을 실행**하도록 설정할 수 있다
	- tooltip 의 mode 설정은 options > interaction > mode 설정을 default 값으로 한다
		- point: 해당 지점 위의 모든 데이터
		- x: x 축을 따라 존재하는 모든 데이터
		- 이 외에 y, nearest, dataset, index 등이 있다
- interaction mode 는 Customizing 이 가능 하다
	- [(doc) Custom interaction modes](https://www.chartjs.org/docs/latest/configuration/interactions.html#custom-interaction-modes) 

- *stacked bar chart 에 대해, 어느 지점에 hover 해도 툴팁에 모든 label 이 표기되는 예제*
![[Pasted image 20240531085928.png]]
  
```js
tooltip: {
  backgroundColor: TOOLTIP_COLOR,
  mode: 'x',
  callbacks: {
	title: () => '',
	label: (context) => {
	  const dataset = context.dataset as SummaryChartDataset;
	  
	  const data = context.formattedValue;
	  const label = dataset.label || '';
	  const siteId = context.label || '';
	  return t(messageLocation, {
		data,
		label,
		siteId,
	  });
	}
  }
},
```

### references
- [(doc) Options > Interactions > mode](https://www.chartjs.org/docs/latest/configuration/interactions.html#modes)
- research

### connections