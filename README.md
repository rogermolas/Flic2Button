# capacitor-plugin-flic-button

Flic2Button support for react ionic capacitor project

## Install

```bash
npm install capacitor-plugin-flic-button
npx cap sync
```

## API

<docgen-index>

* [`echo(...)`](#echo)
* [`scanForButtons()`](#scanforbuttons)
* [`connectButton(...)`](#connectbutton)
* [`disconnectButton(...)`](#disconnectbutton)
* [`removeAllButtons()`](#removeallbuttons)
* [`addListener(string, ...)`](#addlistenerstring-)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### echo(...)

```typescript
echo(options: { value: string; }) => Promise<{ value: string; }>
```

| Param         | Type                            |
| ------------- | ------------------------------- |
| **`options`** | <code>{ value: string; }</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### scanForButtons()

```typescript
scanForButtons() => Promise<void>
```

--------------------


### connectButton(...)

```typescript
connectButton(options: { buttonId: string; }) => Promise<{ message: string; }>
```

| Param         | Type                               |
| ------------- | ---------------------------------- |
| **`options`** | <code>{ buttonId: string; }</code> |

**Returns:** <code>Promise&lt;{ message: string; }&gt;</code>

--------------------


### disconnectButton(...)

```typescript
disconnectButton(options: { buttonId: string; }) => Promise<{ message: string; }>
```

| Param         | Type                               |
| ------------- | ---------------------------------- |
| **`options`** | <code>{ buttonId: string; }</code> |

**Returns:** <code>Promise&lt;{ message: string; }&gt;</code>

--------------------


### removeAllButtons()

```typescript
removeAllButtons() => Promise<{ message: string; }>
```

**Returns:** <code>Promise&lt;{ message: string; }&gt;</code>

--------------------


### addListener(string, ...)

```typescript
addListener(eventName: string, listenerFunc: (data: any) => void) => Promise<PluginListenerHandle>
```

| Param              | Type                                |
| ------------------ | ----------------------------------- |
| **`eventName`**    | <code>string</code>                 |
| **`listenerFunc`** | <code>(data: any) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### Interfaces


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |

</docgen-api>
