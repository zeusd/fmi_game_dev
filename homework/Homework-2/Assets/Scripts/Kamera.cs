using UnityEngine;

public class Kamera : MonoBehaviour
{
    private Vector3 offset;

    [SerializeField]
    GameObject igra4;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        offset = transform.position - igra4.transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        transform.position = Vector3.Lerp(transform.position, igra4.transform.position + offset, Time.deltaTime);
    }
}
